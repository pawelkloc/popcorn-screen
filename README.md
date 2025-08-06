# Popcorn Screen

An iOS app for browsing and saving your favorite movies and TV series.

## Data source

<img src="https://www.themoviedb.org/assets/2/v4/logos/v2/blue_square_2-d537fb228cf3ded904ef09b136fe3fec72548ebc1fea3fbbd1ad9e36364db38b.svg" alt="TMDB Logo" width="100" />

This product uses the TMDB API but is not endorsed or certified by TMDB.  
Movie data and images provided by [TMDB](https://www.themoviedb.org).


## 🔀 Git Workflow

The `popcorn-screen` project follows a structured Git Flow–inspired workflow, designed for team collaboration and clean code reviews.

### 🌳 Main branches

- `main` – the stable production-ready branch (e.g., for App Store releases)
- `develop` – the active development branch where features are integrated and tested

### 🛠️ Working branches

- `feature/*` – new functionality (e.g., `feature/search-bar`)
- `fix/*` – bug fixes (e.g., `fix/keyboard-dismiss`)

### 🧪 Pull request flow

1. Feature branches are created from `develop`
2. Pull request is opened: `feature/*` → `develop`
3. PR is reviewed by another developer (review required)
4. After approval → merged into `develop`
5. When ready for release → pull request from `develop` → `main` (with review)

### ✅ Branch protection rules

- `main`: direct pushes are disabled; only pull requests are allowed
- `develop`: pull request review is required before merging
- All feature/fix branches must go through a code review process

### 🧠 Tooling & workflow support

- Git + GitHub (with PR review and branch protection)
- GitHub CLI (`gh pr create -B develop -f`)
- Custom `.gitignore` tailored for Xcode projects
- Terminal alias `gpr` for quick pull request creation

---

💬 **Goal:** to maintain a clean, reliable, and review-based development process aligned with best practices in professional iOS development.


Made with 🍿 by Paweł Kloc.
