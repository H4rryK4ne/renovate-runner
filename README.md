# Renovate runner

One-shot, self-hosted Renovate runner for Synology Task Scheduler.

## Initial setup

Clone this repository to the DiskStation:

```sh
git clone git@github.com:H4rryK4ne/renovate-runner.git /volume1/docker/renovate-runner
cd /volume1/docker/renovate-runner
```

Create the local environment file and replace the placeholder with a
fine-grained GitHub personal access token:

```sh
cp renovate.env.example renovate.env
chmod 600 renovate.env
```

Create the persistent directories. The default Renovate image runs as UID
`12021`:

```sh
mkdir -p cache logs
chown 12021:0 cache
chmod 770 cache
chmod 700 run-renovate.sh
```

Run the script manually before scheduling it:

```sh
./run-renovate.sh
```

Logs are written to `logs/renovate-YYYY-MM-DD.log`.

## Synology Task Scheduler

Create a scheduled user-defined script, run it as `root`, and use:

```sh
/bin/sh /volume1/docker/renovate-runner/run-renovate.sh
```

The script:

1. pulls reviewed changes from this repository with `git pull --ff-only` and
   restarts itself when the checked-out revision changes;
2. pulls the Renovate image pinned in `compose.yaml`;
3. runs Renovate once; and
4. removes the stopped container.

The fixed container name prevents overlapping scheduled runs.

## Testing without GitHub changes

Temporarily add this line to the untracked `renovate.env`:

```dotenv
RENOVATE_DRY_RUN=full
```

Remove it after reviewing the logs.

## Security

- Never commit `renovate.env`.
- Review runner configuration and image-update pull requests manually.
- Do not enable automerge for this repository.
- Remove the managed repository from the Mend-hosted Renovate app before
  enabling this runner.
- The `allowedCommands` expression in `config.js` deliberately allows only
  the exact `uv export` command used by `H4rryK4ne/update-mypy-hook`.

See Renovate's documentation for the permissions required by a fine-grained
GitHub token:

https://docs.renovatebot.com/modules/platform/github/#running-using-a-fine-grained-token
