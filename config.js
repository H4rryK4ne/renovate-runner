module.exports = {
  platform: "github",
  gitAuthor: "H4rryK4ne <39696020+H4rryK4ne@users.noreply.github.com>",

  repositories: [
    "H4rryK4ne/renovate-runner",
    "H4rryK4ne/update-mypy-hook",
  ],

  allowedCommands: [
    "^uv export --locked --format requirements\.txt --no-default-groups --no-hashes --no-editable --no-header --output-file requirements\.txt$",
  ],
};

