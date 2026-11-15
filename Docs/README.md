# CI/CD Pipelines -- Beginner-Friendly Hands-On Guide

This README documents the concepts and practical steps covered while
building a Java CI/CD learning project with Git, GitHub Actions, Maven,
and Docker.

> **Project:** `cicd-java-practice`\
> **Platform:** Windows PowerShell, VS Code, GitHub\
> **Java target:** Java 11 (check your `pom.xml` configuration)

------------------------------------------------------------------------

### 1. What is CI/CD?

### Continuous Integration (CI)

Continuous Integration means regularly merging code changes into a
shared repository and automatically checking those changes.

A typical CI process:

1.  A developer changes Java code.
2.  The developer pushes the changes to GitHub.
3.  GitHub Actions starts a workflow.
4.  The workflow checks out the code.
5.  Maven compiles the application.
6.  Automated tests run.
7.  The workflow reports success or failure.

The goal is to find problems early.

### Continuous Delivery and Continuous Deployment (CD)

Both terms describe the process of getting tested software ready for
use.

-   **Continuous Delivery:** The application is built and validated
    automatically, and a release or deployment can be approved manually.
-   **Continuous Deployment:** Every change that passes the required
    checks is automatically deployed.

A simple overall flow:

``` text
Developer writes code
        |
        v
Push code to GitHub
        |
        v
GitHub Actions workflow starts
        |
        v
Maven build and tests
        |
        v
Build Docker image
        |
        v
Push image to a container registry
        |
        v
Deploy application
        |
        v
Verify application
```

------------------------------------------------------------------------

## 2. Main tools and their purposes

  -----------------------------------------------------------------------
  Tool                                Purpose
  ----------------------------------- -----------------------------------
  Git                                 Tracks code changes on your
                                      computer

  GitHub                              Hosts the Git repository and
                                      supports collaboration

  GitHub Actions                      Runs automated workflows

  YAML                                Configuration format used to define
                                      workflows

  Java                                Programming language used for the
                                      application

  Maven                               Builds Java applications, manages
                                      dependencies, and runs tests

  Docker                              Packages an application and its
                                      runtime into an image

  Docker Hub                          Stores and shares Docker images

  Google Artifact Registry            Stores container images in Google
                                      Cloud

  Kubernetes                          Runs and manages containerized
                                      applications

  Cloud Run                           Runs containers on Google Cloud
                                      without managing servers
  -----------------------------------------------------------------------

These tools have different responsibilities. For example, Maven builds
and tests the Java project; Docker packages it; a registry stores the
image; and a deployment platform runs it.

------------------------------------------------------------------------

## 3. Git and GitHub basics

### Git vs GitHub

-   **Git** is the version-control tool installed on your computer.
-   **GitHub** is an online service where Git repositories can be stored
    and shared.
-   **GitHub Actions** automates tasks such as building, testing, and
    deploying the application.

### Common Git commands

Run these commands from your project folder:

``` powershell
git status
```

Shows changed, staged, and untracked files.

``` powershell
git checkout -b feature/sample
```

Creates and switches to a new branch.

``` powershell
git add .
```

Stages changes for the next commit.

``` powershell
git commit -m "Add Java application"
```

Saves the staged changes in Git history.

``` powershell
git push -u origin feature/sample
```

Pushes the branch to GitHub and sets its upstream tracking branch.

### Typical branch workflow

``` text
main
 |
 +---- feature/sample
          |
          +-- Edit code
          +-- Commit changes
          +-- Push branch
          +-- Create Pull Request
          +-- Review and merge
```

A feature branch lets you work on changes without directly changing the
main branch.

------------------------------------------------------------------------

## 4. GitHub Actions fundamentals

GitHub Actions is GitHub's automation platform.

A workflow is a YAML file that defines what should happen when an event
occurs.

Workflow files are stored in:

``` text
.github/
└── workflows/
    └── cicd.yaml
```

### Important terms

  Term              Meaning
  ----------------- ----------------------------------------------
  Workflow          Complete automation definition
  Event / Trigger   Event that starts a workflow, such as `push`
  Job               Group of steps executed on a runner
  Runner            Machine that executes a job
  Step              One task inside a job
  Action            Reusable unit of automation
  `run`             Executes a shell command
  `uses`            Uses a reusable action

### Example workflow

``` yaml
name: Hello Workflow

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  hello:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Print a message
        run: echo "Hello from GitHub Actions!"
```

Explanation:

-   `name` gives the workflow a readable name.
-   `on` defines its triggers.
-   `push` starts it when code is pushed to `main`.
-   `workflow_dispatch` allows a manual run from GitHub.
-   `jobs` contains the jobs.
-   `runs-on` selects the runner.
-   `steps` contains the tasks.
-   `uses` calls a reusable action.
-   `run` executes a command.

### GitHub-hosted vs self-hosted runners

-   **GitHub-hosted runner:** A virtual machine managed by GitHub.
-   **Self-hosted runner:** A machine managed by your organization.

A self-hosted runner can provide access to internal systems, but the
organization must maintain and secure it.

### `run` vs `uses`

``` yaml
- name: Show Java version
  run: java -version
```

`run` executes a command.

``` yaml
- name: Checkout repository
  uses: actions/checkout@v4
```

`uses` runs an existing GitHub Action.

------------------------------------------------------------------------

## 5. Important GitHub Actions concepts

### Workflow triggers

Common triggers include:

``` yaml
on:
  push:
    branches:
      - main
      - develop

  pull_request:
    branches:
      - main

  workflow_dispatch:
```

-   `push`: runs after a push to the selected branches.
-   `pull_request`: runs for matching pull-request activity.
-   `workflow_dispatch`: allows a user to start the workflow manually.

### Environment variables

Environment variables store configuration values that are not
confidential.

``` yaml
env:
  JAVA_VERSION: "11"
```

They can be used by workflow steps:

``` yaml
- name: Print Java version setting
  run: echo "${{ env.JAVA_VERSION }}"
```

### Secrets

Secrets store confidential values such as tokens and passwords.

Create them in the repository's **Settings → Secrets and variables →
Actions** section.

Use them in a workflow like this:

``` yaml
- name: Example authenticated command
  env:
    API_TOKEN: ${{ secrets.API_TOKEN }}
  run: echo "The token is available to this step."
```

Do not print secrets or commit them to the repository.

### Jobs and `needs`

Jobs can run independently or depend on other jobs.

``` yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Build"

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - run: echo "Deploy after build"
```

`needs: build` means the deploy job waits for the build job to complete
successfully.

### Conditions

Conditions control whether a step or job runs.

``` yaml
if: success()
```

Runs when previous steps have succeeded.

``` yaml
if: failure()
```

Runs when a previous step or job has failed.

``` yaml
if: always()
```

Runs regardless of the success or failure of earlier steps, subject to
workflow cancellation and other conditions.

``` yaml
if: cancelled()
```

Runs when the workflow has been cancelled.

### Concurrency

Concurrency can prevent multiple runs in the same group from running at
the same time.

``` yaml
concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true
```

This groups runs by Git reference and cancels an older in-progress run
in the same group when a newer one starts.

### Reusable workflows and `workflow_call`

A workflow can be called by another workflow.

``` yaml
on:
  workflow_call:
    secrets:
      API_TOKEN:
        required: true
```

This is useful when several repositories or workflows need to reuse the
same build or deployment process.

A reusable workflow is invoked with the `uses` keyword at the job level
in the calling workflow.

### Step outputs

A step can publish an output that later steps can read.

``` yaml
- name: Set short commit SHA
  id: set_sha
  run: echo "short_sha=${GITHUB_SHA::7}" >> "$GITHUB_OUTPUT"

- name: Display short SHA
  run: echo "${{ steps.set_sha.outputs.short_sha }}"
```

Here:

-   `id: set_sha` gives the step an identifier.
-   `GITHUB_OUTPUT` records the output.
-   `steps.set_sha.outputs.short_sha` reads that output later.

### Artifacts and cache

**Artifacts** preserve files produced by a workflow, such as test
reports or JAR files.

``` yaml
- name: Upload JAR artifact
  uses: actions/upload-artifact@v4
  with:
    name: java-application
    path: target/*.jar
```

**Cache** reuses downloaded dependencies between workflow runs to make
builds faster. For Maven, `actions/setup-java` can configure Maven
dependency caching.

An artifact is a workflow output to retain or download. A cache is
primarily for reusing dependencies or other files to speed up later
runs.

### Service containers

GitHub Actions can start supporting containers for a job, for example a
database used by integration tests. A service container is not the same
thing as the Docker image that you build and publish for your
application.

------------------------------------------------------------------------

## 6. Java and Maven project

Maven is a build tool for Java. It manages dependencies and provides
standard commands to compile, test, and package the project.

### Example project structure

``` text
cicd-java-practice/
├── .github/
│   └── workflows/
│       └── cicd.yaml
├── src/
│   ├── main/
│   │   └── java/
│   │       └── Hello.java
│   └── test/
│       └── java/
│           └── HelloTest.java
├── Dockerfile
├── pom.xml
└── README.md
```

### Example Java application

File: `src/main/java/Hello.java`

``` java
public class Hello {

    public String sayHello() {
        return "Hello, CI/CD!";
    }

    public static void main(String[] args) {
        Hello obj = new Hello();
        System.out.println(obj.sayHello());
    }
}
```

-   `sayHello()` returns a message.
-   `main()` is the entry point used when running the application.
-   The application prints `Hello, CI/CD!`.

### What is `pom.xml`?

`pom.xml` is Maven's Project Object Model file. It defines project
information, dependencies, build settings, and plugins.

For example, it can specify:

-   Group ID, artifact ID, and version.
-   Java compilation settings.
-   JUnit dependencies.
-   Maven compiler and test plugins.
-   JAR packaging configuration.

### Common Maven commands

Run these commands from the folder containing `pom.xml`.

``` powershell
mvn -version
```

Displays Maven and Java version information.

``` powershell
mvn clean
```

Removes the previous build output, normally the `target` directory.

``` powershell
mvn compile
```

Compiles the main Java source code.

``` powershell
mvn test
```

Compiles and runs the configured tests.

``` powershell
mvn package
```

Packages the compiled application, usually as a JAR file.

``` powershell
mvn clean verify
```

Runs the Maven lifecycle through verification, including compilation and
configured tests.

The generated JAR is normally found under:

``` text
target/
```

For this practice project, its name may be:

``` text
target/cicd-java-practice-1.0-SNAPSHOT.jar
```

### Example JUnit test

File: `src/test/java/HelloTest.java`

``` java
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

public class HelloTest {

    @Test
    void testSayHello() {
        Hello obj = new Hello();
        assertEquals("Hello, CI/CD!", obj.sayHello());
    }
}
```

This test checks whether `sayHello()` returns the expected message.

For the test to run, the JUnit dependency and a compatible Maven test
plugin/configuration must be present in `pom.xml`.

A successful Docker run does not prove that JUnit tests passed. Use
`mvn test` or `mvn clean verify` to run the tests

------------------------------------------------------------------------

## 7. Build a Java CI pipeline with GitHub Actions

Create this file:

``` text
.github/workflows/cicd.yaml
```

Example:

``` yaml
name: Java Maven CI Pipeline

on:
  push:
    branches:
      - main
      - 'feature/**'
  pull_request:
    branches:
      - main
  workflow_dispatch:

jobs:
  build:
    name: Build and Test Java Application
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Java
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '11'
          cache: maven

      - name: Check versions
        run: |
          java -version
          mvn -version

      - name: Build and test with Maven
        run: mvn --batch-mode clean verify

      - name: Upload JAR artifact
        uses: actions/upload-artifact@v4
        with:
          name: java-application
          path: target/*.jar
```

### What happens in this pipeline?

1.  GitHub detects a matching push or pull request.
2.  GitHub starts an Ubuntu runner.
3.  `actions/checkout` downloads the repository source.
4.  `actions/setup-java` installs the selected Java distribution and
    configures Maven caching.
5.  Maven runs `clean verify`.
6.  If the build and tests succeed, the JAR is uploaded as a workflow
    artifact.
7.  If a required step fails, the workflow reports failure.

The JAR artifact is available from the GitHub Actions run. Uploading it
does not publish a Docker image.

------------------------------------------------------------------------

## 8. Docker fundamentals

Docker packages an application and the runtime it needs into an image.

### Important Docker terms

  Term         Meaning
  ------------ -----------------------------------------------------
  Dockerfile   Instructions for building an image
  Image        Packaged application template
  Container    A running or stopped instance created from an image
  Registry     A service that stores and distributes images
  Tag          A label used to identify an image version

### Dockerfile for the Java application

File: `Dockerfile`

``` dockerfile
FROM eclipse-temurin:11-jre

WORKDIR /app

COPY target/*.jar app.jar

ENTRYPOINT ["java", "-cp", "app.jar", "Hello"]
```

Explanation:

-   `FROM eclipse-temurin:11-jre`: starts from an image containing a
    Java 11 runtime.
-   `WORKDIR /app`: sets the working directory inside the image.
-   `COPY target/*.jar app.jar`: copies the built JAR into the image.
-   `ENTRYPOINT`: defines the command used to start the Java
    application.

### What does `-cp` mean?

`-cp` means classpath.

``` text
java -cp app.jar Hello
```

It tells Java to look for the `Hello` class inside `app.jar` and run its
`main()` method.

The `-jar` option is another way to run a JAR, but it expects the JAR
manifest to specify a `Main-Class` entry.

For example:

``` text
java -jar app.jar
```

A JAR with a `main()` method is not automatically executable using
`-jar`; the manifest must identify the main class.

### Build the Docker image

Run from the project root, after building the JAR:

``` powershell
docker build -t my-java-app:latest .
```

-   `docker build`: builds an image.
-   `-t`: assigns a name and tag.
-   `my-java-app:latest`: local image name and tag.
-   `.`: uses the current directory as the build context.

### Check local images

``` powershell
docker images
```

### Run a container

``` powershell
docker run --name java-container my-java-app:latest
```

This creates and starts a container from the image.

Expected application output:

``` text
Hello, CI/CD!
```

If a container with the same name already exists, remove it before
creating another container with that name:

``` powershell
docker rm java-container
```

To view running containers:

``` powershell
docker ps
```

To view running and stopped containers:

``` powershell
docker ps -a
```

To remove an image, after no container is using it:

``` powershell
docker rmi my-java-app:latest
```

Remember:

-   `docker rm` removes a container.
-   `docker rmi` removes an image.

------------------------------------------------------------------------

## 9. Docker image vs container

A simple comparison:

  -----------------------------------------------------------------------
  Docker image                        Docker container
  ----------------------------------- -----------------------------------
  A packaged template                 An instance created from an image

  Built using a Dockerfile            Created using `docker run`

  Can be stored in a registry         Runs on a Docker host

  Can be used to create many          Represents one container instance
  containers                          
  -----------------------------------------------------------------------

Example:

``` text
Dockerfile
    |
    v
Docker image: my-java-app:latest
    |
    +----> Container 1
    |
    +----> Container 2
```

You can create multiple containers from the same image.

------------------------------------------------------------------------

## 10. Publish an image to Docker Hub

Docker Hub is a registry where you can store and share Docker images.

First, create a repository on [Docker Hub](https://hub.docker.com/), for
example:

``` text
cicd-java-practice
```

Then use PowerShell.

### Step 1: Sign in

``` powershell
docker login
```

Complete the sign-in prompt. Do not put your password or access token in
a command that you share.

### Step 2: Tag your local image

Replace `YOUR_DOCKERHUB_USERNAME` with your Docker Hub username:

``` powershell
docker tag my-java-app:latest YOUR_DOCKERHUB_USERNAME/cicd-java-practice:v1
```

This adds a registry-compatible name to the existing local image. It
does not rebuild the image.

### Step 3: Push the image

``` powershell
docker push YOUR_DOCKERHUB_USERNAME/cicd-java-practice:v1
```

Docker uploads the image to Docker Hub.

### Step 4: Verify

Open Docker Hub, select your repository, and check its **Tags** page for
`v1`.

### Step 5: Pull the image (optional verification)

On a machine with Docker installed, you can pull the published image:

``` powershell
docker pull YOUR_DOCKERHUB_USERNAME/cicd-java-practice:v1
```

You can then run it using:

``` powershell
docker run --name java-container-test YOUR_DOCKERHUB_USERNAME/cicd-java-practice:v1
```

Use a container name that is not already in use.

------------------------------------------------------------------------

## 11. What comes after publishing the image?

After the image is available in a registry, it can be deployed to a
platform that runs containers.

### Google Cloud Run

Cloud Run runs containers without requiring you to manage the underlying
servers. It is useful for many web services and HTTP applications.

Typical flow:

``` text
GitHub
  |
  v
GitHub Actions
  |
  v
Maven build and tests
  |
  v
Docker image build
  |
  v
Push image to Artifact Registry
  |
  v
Deploy image to Cloud Run
```

A Java command-line program that only prints a message is useful for
learning Docker, but it is not yet a web service. To deploy a web
application to Cloud Run, the application normally needs to listen for
HTTP requests on the port provided through the `PORT` environment
variable.

### Kubernetes

Kubernetes manages containerized applications across a cluster.

Common Kubernetes resources include:

-   **Deployment:** manages application replicas and updates.
-   **Pod:** runs one or more containers.
-   **Service:** provides a stable way to access a group of Pods.
-   **ConfigMap:** stores non-confidential configuration.
-   **Secret:** stores sensitive configuration data.

Typical flow:

``` text
GitHub
  |
  v
GitHub Actions
  |
  v
Build and test Java application
  |
  v
Build Docker image
  |
  v
Push image to registry
  |
  v
Deploy to Kubernetes
  |
  v
Verify Pods and Service
```

Cloud Run and Kubernetes are different deployment options. You do not
need both for every application.

------------------------------------------------------------------------

## 12. Common troubleshooting

### Docker cannot connect to Docker Desktop

If Docker reports that it cannot connect to the Docker engine:

1.  Open Docker Desktop.
2.  Wait until the engine is running.
3.  Check:

``` powershell
docker info
```

If the engine is not available, resolve the Docker Desktop or Docker
context issue before building or running containers.

### Container name already exists

If Docker says the container name is already in use:

``` powershell
docker ps -a
docker rm java-container
```

Then run the container again.

### Main method not found

Java needs an entry point when starting a class directly:

``` java
public static void main(String[] args) {
    // application starts here
}
```

For this project, the Docker command uses:

``` dockerfile
ENTRYPOINT ["java", "-cp", "app.jar", "Hello"]
```

### Maven reports zero tests

Check that:

-   The test file is under `src/test/java`.
-   The test uses a supported test framework such as JUnit 5.
-   The JUnit dependency is present in `pom.xml`.
-   The test class and method follow the test framework's discovery
    rules.

Run:

``` powershell
mvn test
```

### Docker image runs an older version of the code

After changing Java code:

1.  Build the JAR again.
2.  Rebuild the Docker image.
3.  Run a new container.

``` powershell
mvn clean package
docker build -t my-java-app:latest .
docker run --name java-container-new my-java-app:latest
```

------------------------------------------------------------------------

## 13. Current project progress

Use this checklist to track your practice:

-   [x] Understand CI and CD basics.
-   [x] Learn Git and GitHub basics.
-   [x] Create a Java Maven project.
-   [x] Understand GitHub Actions workflows, jobs, steps, runners, and
    triggers.
-   [x] Configure a Maven CI workflow.
-   [x] Get a successful GitHub Actions build.
-   [x] Create a Dockerfile.
-   [x] Build a local Docker image.
-   [x] Run the Java application inside a Docker container.
-   [ ] Confirm JUnit tests pass with `mvn test`.
-   [ ] Create a Docker Hub repository.
-   [ ] Push the image to Docker Hub.
-   [ ] Automate Docker image build and push in GitHub Actions.
-   [ ] Learn deployment to Cloud Run.
-   [ ] Learn deployment to Kubernetes.

Update this checklist as you complete each stage.

------------------------------------------------------------------------

## 14. Useful commands -- quick reference

### Git

``` powershell
git status
git add .
git commit -m "Describe your changes"
git push
```

### Maven

``` powershell
mvn -version
mvn clean
mvn compile
mvn test
mvn package
mvn clean verify
```

### Docker

``` powershell
docker images
docker build -t my-java-app:latest .
docker run --name java-container my-java-app:latest
docker ps
docker ps -a
docker login
docker tag my-java-app:latest YOUR_DOCKERHUB_USERNAME/cicd-java-practice:v1
docker push YOUR_DOCKERHUB_USERNAME/cicd-java-practice:v1
docker pull YOUR_DOCKERHUB_USERNAME/cicd-java-practice:v1
docker rm java-container
docker rmi my-java-app:latest
```

------------------------------------------------------------------------

## 15. Official documentation

-   [Git documentation](https://git-scm.com/doc)
-   [GitHub Actions documentation](https://docs.github.com/en/actions)
-   [Maven documentation](https://maven.apache.org/guides/)
-   [Docker documentation](https://docs.docker.com/)
-   [Docker Hub](https://hub.docker.com/)
-   [Google Cloud Run documentation](https://cloud.google.com/run/docs)
-   [Google Artifact Registry
    documentation](https://cloud.google.com/artifact-registry/docs)
-   [Kubernetes documentation](https://kubernetes.io/docs/home/)

------------------------------------------------------------------------

## Final learning goal

The goal of this project is to understand and practise the complete
delivery flow:

**Code → GitHub → GitHub Actions → Maven build and tests → Docker image
→ Container registry → Deployment → Verification**

Keep practising one stage at a time. Make sure each stage works before
automating the next one.
