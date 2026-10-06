# CloudNotes release repair

40-minute, 20-mark Cloud Computing Summative Internal Exam (Modules 1–3).
Full task instructions and rubric: [assessment.md](assessment.md).
Repair three release configurations. Application and helpers already work.
CloudNotes is a stateless release-verification fixture, not a complete notes application.

**Everything runs locally; no GCP account or cloud deployment is required.**

## Start

Fork https://github.com/kalviumcommunity/cloudnotes-ca-release on GitHub, then clone your own fork. Replace `<your-username>` with your GitHub username.

```bash
git clone https://github.com/<your-username>/cloudnotes-ca-release.git
cd cloudnotes-ca-release
git checkout -b fix/cloudnotes-release
```

Before the timer, instructor prepares Terraform 1.5+ (below 2.0), running Docker/Compose, Git/GitHub access, curl, and available ports 8080/5001. Instructor starts a loopback-only registry:

```bash
docker run -d --name cloudnotes-ca-registry -p 127.0.0.1:5001:5000 registry:2
```

Instructor resolves occupied names/ports; do not remove unknown containers. Instructor validates this registry with the lab Docker configuration, caches `node:22-bookworm`, `node:22-bookworm-slim`, `registry:2` and the tested Google provider for the exam architecture, checks provider init per clone or supplies a configured plugin cache, and runs `bash scripts/preflight.sh` before the timer. Never commit `.terraform`.

## Repair requirements

Edit only these files:

1. **Terraform:** `terraform/main.tf`, `terraform/modules/storage/main.tf`. Use declared root inputs for bucket name, region and expiry. Exports must have uniform bucket-level access, enforced public-access prevention, and a deletion lifecycle at the configured age (default 30 days). Current policy is unsafe/incomplete, not proof of an exposed bucket; no real bucket or public IAM binding exists. Explain why exports remain private and why state belongs outside Git. Successful validation alone does not prove the design correct.
2. **Image:** `Dockerfile`. Retain the build stage; rewrite the complete runtime section (six substantive instruction changes). Use official `node:22-bookworm-slim`, work directory `/app`, only packaged `dist` copied from the named build stage, files accessible to the existing `node` user, a non-root process, port 8080, and launch the packaged server.
3. **Compose:** `compose.yaml`. Run the already-built version 1.0.0 image. Listen on all container interfaces at 8080, publish only host loopback at 8080, use production mode, disable privileged execution, and limit to 0.5 CPU/128 MB. Use documented [`cpus`](https://docs.docker.com/reference/compose-file/services/#cpus) and [`mem_limit`](https://docs.docker.com/reference/compose-file/services/#mem_limit) fields. Do not add builds, source mounts, or a root-user override. Distinguish container listening address from host publishing address.

Formatting does not count as repair. Terraform requires three root argument changes, two access changes and a lifecycle block; Compose requires at least seven meaningful scalar changes. Do not change application, helpers or module input interface to hide faults.

Initial Terraform init should succeed; validate should fail for undeclared `storage_region`. Initial Docker build may succeed but image/runtime settings are wrong. Compose is valid YAML but does not meet release requirements. Google project ID is fictional; validation does not authenticate or provision it.

## Verify

Run from repository root after repairs:

```bash
terraform -chdir=terraform init
terraform -chdir=terraform fmt -recursive
terraform -chdir=terraform validate
docker build -t cloudnotes:1.0.0 .
docker image inspect cloudnotes:1.0.0 --format '{{.RepoTags}} user={{.Config.User}}'
bash scripts/publish-local.sh
docker compose config --quiet
docker compose up -d
docker compose ps
curl -i http://localhost:8080/health
```

After changing settings, use `docker compose up -d --force-recreate`. Wait a few seconds and retry curl during startup. Expect HTTP 200 and JSON status `ok`, service `cloudnotes`, mode `production`. Other paths return JSON 404. Application defaults are host `0.0.0.0`, port `8080`, mode `development`.

Publish helper explicitly pushes/pulls the version through the prepared local registry, reports its RepoDigest, and retags the pulled image for Compose. A cached pull verifies registry reachability and artifact identity, not an independent clean-machine download.

## Submit

Commit and push your repairs to your fork; no pull request needed. Submit one PDF named `<student-id>_CloudNotes.pdf`, with your name, student ID and fork URL. Include **exactly three actual screenshots**, one readable editor/terminal split capture per task, not collages. Label sections Task 1–3 and caption each screenshot:

- Task 1: both repaired Terraform sections and successful validation. Two-sentence explanation: private exports and state outside Git.
- Task 2: repaired runtime stage, successful build and image tag/user inspection. Two-sentence explanation: build/runtime separation and non-root execution.
- Task 3: repaired web service, registry digest, running-service status and HTTP 200 production response. Two-sentence explanation: container listening address and version tags.

Put explanations beneath screenshots as PDF text. No extra screenshots or ZIP. Do not fabricate output. Instructor checks committed fixes, including runtime security and limits; no additional student evidence beyond the assessment is required.

Do not run Terraform plan/apply or outputs, provision cloud resources, install scanners, or add Kubernetes, CI/CD YAML, autoscaling or monitoring setup. No state migration or remote backend is needed.

Optional cleanup after submission: `docker compose down`. Instructor owns registry cleanup.
