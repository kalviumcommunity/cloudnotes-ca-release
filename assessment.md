# Summative Internal Exam: Repair the CloudNotes Release

**Course:** Cloud Computing — Modules 1–3

**Duration:** 40 minutes | **Marks:** 20

**Submission:** One PDF containing **exactly three screenshots**

## Problem Statement

A teammate has prepared CloudNotes for release, but three parts need repair:

1. The Terraform storage configuration has incorrect inputs and incomplete protection settings.
2. The Docker image includes unnecessary files and runs with excessive permissions.
3. The Compose configuration uses incorrect connection settings and runtime limits.

Repair these configurations and prove that CloudNotes builds and runs locally. The application code and helper scripts are already provided; you do not need to write an application from scratch. CloudNotes is a stateless release-verification fixture, not a complete notes application.

**Everything runs locally. No GCP account or cloud deployment is required.** Your instructor will prepare the required tools and local registry before the exam.

## Broken Repository: Fork and Clone First

**Repository:** https://github.com/kalviumcommunity/cloudnotes-ca-release

1. Open the repository on GitHub and click **Fork** to copy it into your account.
2. Clone your fork and create a working branch. Replace `<your-username>` with your GitHub username:

```bash
git clone https://github.com/<your-username>/cloudnotes-ca-release.git
cd cloudnotes-ca-release
git checkout -b fix/cloudnotes-release
```

3. Read `README.md`. Locate `terraform/`, `Dockerfile`, and `compose.yaml`.
4. Complete the three tasks below. Keep the provided application, module inputs/outputs, and helper scripts unchanged. Do not bypass checks or add real credentials.

Run all verification commands from the repository's main folder. Initially, Terraform init should succeed but validation should fail for undeclared `storage_region`. The initial Docker image may build; its release layout and permissions are still wrong. Compose parses but does not meet the release requirements.

## Task 1: Repair the Storage Configuration

**Files:** `terraform/main.tf` and `terraform/modules/storage/main.tf`

CloudNotes models a private bucket for temporary exported notes. These exports should be deleted after **30 days**. No real bucket is created in this exam; the initial access policy is unsafe/incomplete, not evidence of an exposed bucket.

1. Fix the root module call so its bucket name, location, and expiry value come from the existing root variables. Pass them to the matching storage-module inputs.
2. Update the storage resource to enable uniform bucket-level access and enforce public access prevention.
3. Add a lifecycle rule that deletes exports at the age specified by the module's `expiry_days` input. Keep the module reusable; do not hardcode the age inside the resource.
4. Format and validate the repaired configuration:

```bash
terraform -chdir=terraform init
terraform -chdir=terraform fmt -recursive
terraform -chdir=terraform validate
```

**Expected result:** Successful validation, correct module inputs, private-access settings, and the configured deletion rule. Do not run Terraform plan or apply. Validation alone does not prove that all design requirements are met.

**Screenshot 1:** Show both repaired code sections and successful validation together, using split editor panes and the terminal.

**Explain in two sentences:** Why should exports remain private, and why should Terraform state stay out of Git?

## Task 2: Repair the Container Runtime

**File:** `Dockerfile`

The first stage already packages the server into `/app/dist/server.js`. Keep that stage and repair the final runtime stage.

1. Use the official `node:22-bookworm-slim` runtime base and `/app` working directory.
2. Copy only the packaged `dist` directory from the build stage. Ensure the existing `node` user can access it; do not copy the whole repository into the runtime image.
3. Run as the unprivileged `node` user, declare port **8080**, and start the packaged server.
4. Build and inspect the image:

```bash
docker build -t cloudnotes:1.0.0 .
docker image inspect cloudnotes:1.0.0 --format '{{.RepoTags}} user={{.Config.User}}'
```

**Expected result:** Successful build, version tag `cloudnotes:1.0.0`, and runtime user `node`.

**Screenshot 2:** Show the repaired runtime stage beside successful build and image-inspection output.

**Explain in two sentences:** Why separate build files from runtime files, and why run as non-root?

## Task 3: Repair and Verify the Local Release

**File:** `compose.yaml` — the `web` service

Make the service use your repaired image and accept requests from your laptop safely.

1. Select image `cloudnotes:1.0.0`. Set the application environment to listen on all container interfaces at port **8080**, with mode `production`.
2. Publish container port **8080** to your laptop's **127.0.0.1:8080** only.
3. Disable privileged execution. Set `cpus` to **0.5** and `mem_limit` to **128m**.
4. Publish and pull the image through the prepared local registry using the supplied script, then start and check the service:

```bash
bash scripts/publish-local.sh
docker compose config --quiet
docker compose up -d
docker compose ps
curl -i http://localhost:8080/health
```

Do not add `build:`, source bind mounts, or a root-user override. After changing settings or republishing, use `docker compose up -d --force-recreate`. Wait a few seconds and retry curl if the application is starting. The registry is prepared by the instructor, not a service you need to add or repair.

**Expected result:** Successful registry push/pull with an image digest, running service, and HTTP **200** response containing `"status":"ok"` and `"mode":"production"`. A cached pull verifies the local registry round-trip and artifact identity, not an independent clean-machine download.

**Screenshot 3:** Show the repaired `web` configuration beside the registry digest, running-service status, and health response. The supplied script prints a concise summary.

**Explain in two sentences:** Why must the app listen beyond container-local loopback, and how does a version tag help identify a release?

Commit and push your repaired files to your fork. A pull request is not required.

## Submission

Upload one PDF named **`<student-id>_CloudNotes.pdf`**; replace `<student-id>` with your student ID. Include your name, student ID and fork URL as PDF text, plus:

- Three sections labelled **Task 1**, **Task 2**, and **Task 3**.
- Exactly **one readable screenshot per task**, each with a short caption.
- The requested two-sentence explanations beneath each screenshot.

Use one actual editor/terminal capture per task, not a collage. Your committed source changes will be checked through your fork. No additional screenshots or ZIP are needed.

Do not provision cloud resources, run Terraform plan/apply or outputs, install scanners, or add Kubernetes, CI/CD YAML, autoscaling or monitoring setup. Optional cleanup after submission: `docker compose down`. Instructor owns registry cleanup.

## Rubric

| Division | Criteria | Marks |
|---|---|---:|
| Task 1 | Correct module inputs (2); access settings and lifecycle rule (2); validation and explanations (2). | 6 |
| Task 2 | Correct multi-stage runtime files (2); slim base, non-root user, port and startup (2); build verification and explanations (2). | 6 |
| Task 3 | Image, environment and port mapping (2); privileges and limits (1); registry and health verification (2); explanations (1). | 6 |
| Labels and submission | Three labelled screenshots with captions (1); correctly named PDF, student details, and fork containing committed fixes (1). | 2 |
| **Total** | | **20** |

Partial credit applies to independently correct steps. If a prepared tool or service fails, inform your instructor; do not invent evidence.
