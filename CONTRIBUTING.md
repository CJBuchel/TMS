# Contributing to TMS

## Getting Started
**Prerequisites:**
- [Rust](https://rust-lang.org/tools/install/)
- [Flutter](https://docs.flutter.dev/install)
- [Protobuf](https://protobuf.dev/installation/)
- [Pre-Commit](https://pre-commit.com/) (optional but recommended)

**The dart protobuf plugin requires "$HOME/.pub-cache/bin" to be added to your PATH**

**Installation:**
1. Clone and install the pre-commit hooks:
   ```bash
   git clone https://github.com/<USERNAME>/TMS.git
   cd TMS
   pre-commit install
   ```
2. Build the server:
   ```bash
   cargo build
   ```
3. Install client dependencies:
   ```bash
   dart pub global activate protoc_plugin
   cd client
   flutter pub get
   ```

**Compiling**
1. Compile the server (from workspace)
- If protobuf is installed the buildscript should automatically compile the protobuf files into generated outputs prior to compiling the server.
   ```bash
   cargo build
   ```
2. Compile the client
- The Flutter client uses protobuf, riverpod and freezed which generates code for state management and data models.
- It's recommended to run the build_runner to generate any lingering code. Or run it with `watch` to automatically regenerate code.
- And then compile the protobuf (flutter sadly doesn't have a build_runner binding for protobuf)
   ```bash
   protoc --proto_path=protos --dart_out=grpc:client/lib/generated protos/**/*.proto
   cd client
   dart run build_runner build --delete-conflicting-outputs
   flutter build
   ```

## Project Structure
| **Directory** | **Description** |
|---------------|-----------------|
| `/database` | key-value database library using sled |
| `/launcher` | Launcher and entry code for the server application |
| `/protos` | Protocol Buffers definitions for communication between client and server |
| `/server` | Server-side code |
| `/client` | Client-side code (in flutter) |
| `/docs` | Documentation for the project |

<!--### TODO-->
<!-- Explain vertical slice domain architecture in modules -->

## Development Workflow

**Branch Naming Convention:**
- `feat/<feature-name>`
- `fix/<issue-number>`

**Committing:**
- TMS uses pre-commit hooks for linting and catching common issues before committing
- Use conventional and meaningful commit messages: `feat:`, `fix:`, `docs:`, `refactor:`
- Keep commit messages concise and descriptive under 50 characters
- Example: `fix: Updated export column order to match OJS`

**Pull Requests:**
1. Create feature branch from `master`
2. Make changes, test locally
3. Update documentation relating to feature if possible
4. Push and open PR to `master`
5. Ensure CI-CD is compliant with changes
6. Prefer squash merge

## Code Style

**Rust:**
- Use Rustfmt for code formatting
- Use `2 spaces` for indentation
- Use `120 line width`
- Use `snake_case` for variable and function names
- Use `PascalCase` for struct, trait and enum names
- Use consistent naming conventions

**Flutter:**
- Use `2 spaces` for indentation
- Use `120 line width`
- Use `camelCase` for variable and function names
- Use `PascalCase` for class, enum and interface names
- Use consistent naming conventions

## Programming Guidelines **Flutter**
- Order of Widget priority
  - `StatelessWidget` for static content
  - `ConsumerWidget` for rebuilding content (dependent on providers)
  - `HooksConsumerWidget` for rebuilding content with inline logic

## UI Guidelines

### Font
| **Font Type** | **Font Name** | **Font Size** |
|---------------|---------------|---------------|
| Heading | Ubuntu Mono | 16px |
| Body | Ubuntu Mono | 14px |
| Supporting | Ubuntu Mono | 12px |

**(Yes it's monoblock, I don't want to hear it)**

### Color Palette
| **Color Type** | **Color Name** | **Hex Code** |
|----------------|----------------|--------------|
| Primary | Mint Green | #009485 |
| Secondary | Persian Blue | #009485 |
| Supporting Error | Red | #D92B2B |
| Supporting Warning | Orange | #D9822B |
| Supporting Success | Green | #2BD92B |
| Supporting Info | Blue | #2B65D9 |
| Neutral | Shadow Gray | #20222F |
