# Contributing to MooBench 🚀

Thank you for your interest in contributing to MooBench! We welcome bug reports and any kind of code contributions to the project.

## ✅ How to contribute

### Reporting issues

- Please search existing issues before creating a new one — your problem or idea may already be discussed or solved.  
- When reporting a bug, include as much information as possible: error messages, minimal reproducible example, environment (JVM / Python version, bash version), and expected vs actual behavior.  

### Submitting pull requests (PR)

1. Fork the repository and create a branch with a name that describes your planned contribution.
2. Make sure your code follows the existing style (see README.md).  
3. For all commits, please use descriptive messages.
4. Rebase or merge main upstream if needed; make sure no conflicts remain.
5. Create a PR, describing what you’ve changed and referencing related issues (if any).

Typical PRs include:
- Fixes to documentation or code
- Implementation of new observability framework / language combinations, including new benchmark tools if necessary (the benchmark should follow the style of the Java original benchmark)
- Extension of the analysis capabilities

## 🔧 CI and Tests

Ensure you don't break existing functionality. To do so, we recommend activating GitHub Actions in your fork and running the workflows named execute*.yaml - none of them should fail after an extension.

Thank you for helping make MooBench better! 🎉
