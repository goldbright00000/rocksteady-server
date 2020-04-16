# Application Server

To run server in development mode:

    $ bundle exec bin/run

# Requirements

* Ruby 2.1.2
* MySQL 5.5

# Git/Hg hooks

Currenlty there are precommit hooks for both SCMs to make sure the `bin/*` scripts are executable.

## Put Git hook in place

Copy the `scm_hooks/pre-commit.git` to `.git/hooks/pre-commit`.

## Put HG hook in place

Copy `scm_hooks/precommit.hg` to `bin/precommit.hg` and make it executable.

Then put these lines into `.hg/hgrc`:

```
[hooks]
precommit = bin/precommit.hg
```

# Config Files

## database.yml

This must exist, use the .example file to create it.

## config.yml

This is optional, use it only if you need to override the default settings.

## not-production-server

This must exist in any server that is not production.

# Testing

Tests like unit tests that would be almost impossible to create outside of the codebase are stored in the **/test** direcory. These tests use *minitest* and are run with the `rake minitest:quick` command (to avoid DB reload - *for now at least*)

# Repositories
There are two repos the git repositories and the mercurial, the latest is used to deploy code to the test server.

The mercurial repository is hosted on a server maintained by Chris, it's also where we want to push our code to otherwise your code won't be tested and released.
On the other hand the git repo is hosted on bitbucket, and as far as I'am concerned the only reason for it to exist is to make the contribution of developer more smooth as the majority of developers knows how to work with git.

Both repositories are supposed to be a mirror of each other, although it's true most of the times as it's done manually by the developers it adds room for problems and they might be different for short-period of time as developers pushing to the repos may delay. With all that said, it's the developer's responsibility to push their code to both repositories and coordinate with other developers working on the same project.

# Deploy to test

The code pushed to mercurial wind up on the test server, however, it needs an action beforehand to be deployed.

The code got deployed by a post commit hook, it's important to note that the post commit only runs **when we add '.needs_upgrade' to the root of the project**, I personally prefer to create it directly on the server instead of committing it to the repository.

Following the steps below to have your code  test and deployed on the server:
* Add a '.needs_upgrade' file to the root of the folder
* Push your changes to the mercurial repo.
