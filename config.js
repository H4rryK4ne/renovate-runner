module.exports = {
  platform: "github",

  // repositories: [
  //   "H4rryK4ne/renovate-runner",
  //   "H4rryK4ne/update-mypy-hook",
  // ],
  autodiscover: true,

  allowedCommands: [
    "^uv export --locked --format requirements\.txt --no-default-groups --no-hashes --no-editable --no-header --output-file requirements\.txt$",
  ],
};

