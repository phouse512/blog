[![Build Status](https://travis-ci.org/phouse512/blog.svg?branch=master)](https://travis-ci.org/phouse512/blog)

#### blog

collection of personal thoughts related to technology, life, and other things.

###### dependencies

- jekyll
- docker

###### deployment and operations

This blog is set up for continuous integration and deployment. It also has
a separate stage server hosted alongside http://phizzle.space 

When code is pushed/merged into the `stage` branch, the code is automatically
built and deployed to the stage server using travis ci. Once
satisified with that, you can then merge code from `stage` to `master`, where
the code will be built and deployed directly to http://phizzle.space 

More on branching strategy for this:
- if working on more than one post at once, make sure that work is being done
  on new branches separate than that of `stage` and `master`.
- to test out a post on stage, commit your changes on your 'feature' branch,
  and then run `git checkout stage`. Next, run `git reset --hard
  <feature_branch>` to make stage look like your new post. Force push that to
  the remote stage branch to check it out.

To run the build server locally and watch your local file system:

```
$ make development
```

Deploys happen automatically upon merging to the production branch, using
a docker image to run the deploy.


The blog also has an automated spellcheck incorporated into the test process.
Spellcheck will be run on build before deployment, and can be run locally as
well. `dictionary.txt` holds all exceptions since my content usually has
non-standard vocabulary from software development.

```
# run spellcheck utility on posts
$ make spellcheck
```

