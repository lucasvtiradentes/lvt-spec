## Arguments

<!--@claude,codex-->
- $ARGUMENTS: The topic to research (e.g., "gcloud cli", "docker", "kubernetes")
<!--@gemini-->
- {{args}}: The topic to research (e.g., "gcloud cli", "docker", "kubernetes")
<!--@end-->

## Instructions

1. Web Research: Use WebSearch to find updated 2026 documentation and tutorials about the topic. Search for:
   - Official documentation
   - Getting started guides
   - Common commands/usage
   - Best practices
   - Advanced topics

2. Use Agents: Launch parallel agents to research different aspects of the topic if needed. Each agent should focus on a specific area.
<!--@claude-->
   Use Task tool with `subagent_type="general-purpose"` for each agent.
<!--@end-->

3. Create Folder: Create a folder at `docs/research/{topic-name}/` where topic-name is the argument converted to kebab-case (e.g., "gcloud cli" -> "gcloud-cli").

4. Create Files: Split the research into multiple numbered markdown files:
   - `1-overview.md`       - What it is, installation, core concepts
   - `2-{subtopic}.md`     - Main functionality/commands
   - `3-{subtopic}.md`     - Common use cases/examples
   - `4-{subtopic}.md`     - Advanced topics
   - `5-best-practices.md` - Best practices, tips, troubleshooting, sources

5. File Format:
   - Use tables for commands/options when applicable
   - Include code examples with proper syntax highlighting
   - Keep explanations concise
   - Add sources at the end of the last file
   - Write in English
   - Tables must have "|" aligned vertically:
     ```
     | Command              | Description                              |
     |----------------------|------------------------------------------|
     | `terraform init`     | Initialize directory, download providers |
     | `terraform plan`     | Show changes to be made (dry run)        |
     ```
   - Lists with descriptions must have " - " aligned vertically:
     ```
     1. Remote state       - use GCS bucket with versioning
     2. State locking      - use Cloud Firestore or Terraform Cloud
     3. Secrets            - never hardcode, use Secret Manager
     ```

6. Output: After creating files, show the folder structure created.
