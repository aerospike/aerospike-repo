# [PROJECT_NAME]

> **Note:** This is a template repository. When creating a new repository from this template, replace `[PROJECT_NAME]` with your project name and update this README with your project-specific information.

<!-- Brief description of what your project does -->

## Getting Started

### Development Setup

<!-- Add project-specific setup instructions here -->

```bash
# Clone the repository
git clone https://github.com/aerospike/[REPOSITORY_NAME].git
cd [REPOSITORY_NAME]

# Add your setup steps here
```

## Project Structure

<!-- Describe your project structure here -->

```text
.
├── .github/
│   ├── workflows/       # GitHub Actions workflows
│   └── dependabot.yml   # Dependabot configuration
└── etc
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## Security

For information on reporting security vulnerabilities, please see [SECURITY.md](SECURITY.md).

## Repo Tooling

Linting will be run on PRs; you can save yourself some time and annoyance by linting as you write.

If you use Visual Studio Code or a derivative, there are suggested extensions in the [.vscode](.vscode) directory.

### Trunk

Trunk can also be run as a CLI. Once installed, you can run `trunk git-hooks sync` to check and make sure that your code will pass CI.

### Linter notes

`kennylong.kubernetes-yaml-formatter`: Prettier and this yaml formatter disagree on some rules. If you have yaml format-on-save enabled with kennylong's extension, `trunk check|fmt` will complain about it.

`streetsidesoftware.code-spell-checker`: This isn't enabled via trunk and you should run it in your editor of choice. Trunk marks all misspelled words as errors, when they should properly be be notes (blue squiggles, not red squiggles).

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Support

<!-- Add support information here -->

For questions or issues, please:

- Open an issue on GitHub
- Check existing documentation
- Contact the maintainers

---

**Remember to customize this README for your specific project!**
