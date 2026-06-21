#!/usr/bin/env python3
"""
Generate an operations-friendly AWS Backup summary from backup job JSON.

Offline mode:
  aws backup list-backup-jobs --by-backup-vault-name <vault> > reports/backup-jobs.json
  python scripts/generate_backup_summary.py --input reports/backup-jobs.json

Optional Bedrock mode:
  python scripts/generate_backup_summary.py --input reports/backup-jobs.json --bedrock
"""

from __future__ import annotations

import argparse
import json
import os
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


def load_jobs(path: Path) -> list[dict[str, Any]]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    if isinstance(payload, list):
        return payload
    return payload.get("BackupJobs", []) or payload.get("backup_jobs", []) or []


def summarize_offline(jobs: list[dict[str, Any]]) -> str:
    total = len(jobs)
    states = Counter(str(job.get("State", "UNKNOWN")) for job in jobs)
    resource_types = Counter(str(job.get("ResourceType", "UNKNOWN")) for job in jobs)
    failed_jobs = [job for job in jobs if str(job.get("State", "")).upper() in {"FAILED", "ABORTED", "EXPIRED"}]

    lines = [
        "# AWS Backup Operations Summary",
        "",
        f"Generated at: {datetime.now(timezone.utc).isoformat()}",
        f"Total jobs reviewed: {total}",
        "",
        "## Job status",
    ]

    if states:
        for state, count in states.most_common():
            lines.append(f"- {state}: {count}")
    else:
        lines.append("- No backup jobs found in the input file.")

    lines.extend(["", "## Resource types"])
    if resource_types:
        for resource_type, count in resource_types.most_common():
            lines.append(f"- {resource_type}: {count}")
    else:
        lines.append("- No resource type data found.")

    lines.extend(["", "## Risk notes"])
    if failed_jobs:
        lines.append(f"- Attention required: {len(failed_jobs)} backup job(s) failed or ended abnormally.")
        for job in failed_jobs[:5]:
            lines.append(
                f"  - Job {job.get('BackupJobId', 'unknown')} for {job.get('ResourceArn', 'unknown resource')} ended as {job.get('State')}."
            )
    else:
        lines.append("- No failed, aborted, or expired jobs were found in the provided data.")

    lines.extend([
        "",
        "## Suggested next actions",
        "- Confirm restore testing for at least one recent recovery point.",
        "- Review retention and cross-region copy settings against business RPO/RTO requirements.",
        "- Check CloudWatch/EventBridge/SNS notifications for failed backup visibility.",
    ])
    return "\n".join(lines) + "\n"


def summarize_with_bedrock(summary: str, model_id: str) -> str:
    try:
        import boto3  # type: ignore
    except ImportError as exc:
        raise SystemExit("boto3 is required for --bedrock mode. Install boto3 or run offline mode.") from exc

    client = boto3.client("bedrock-runtime", region_name=os.getenv("AWS_REGION", "us-east-1"))
    prompt = (
        "You are a senior cloud operations engineer. Rewrite this AWS Backup summary into a concise release-risk style report. "
        "Keep it practical, mention risks, and add clear next actions.\n\n"
        f"{summary}"
    )
    body = json.dumps(
        {
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": 600,
            "messages": [{"role": "user", "content": prompt}],
        }
    )
    response = client.invoke_model(modelId=model_id, body=body)
    payload = json.loads(response["body"].read())
    return payload["content"][0]["text"] + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate AWS Backup operations summary.")
    parser.add_argument("--input", required=True, type=Path, help="Path to AWS Backup jobs JSON file.")
    parser.add_argument("--output", default=Path("reports/backup-summary.md"), type=Path, help="Output markdown file path.")
    parser.add_argument("--bedrock", action="store_true", help="Use Amazon Bedrock to rewrite the summary.")
    parser.add_argument(
        "--model-id",
        default="anthropic.claude-3-haiku-20240307-v1:0",
        help="Bedrock model ID used when --bedrock is enabled.",
    )
    args = parser.parse_args()

    jobs = load_jobs(args.input)
    summary = summarize_offline(jobs)
    if args.bedrock:
        summary = summarize_with_bedrock(summary, args.model_id)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(summary, encoding="utf-8")
    print(f"Wrote {args.output}")


if __name__ == "__main__":
    main()
