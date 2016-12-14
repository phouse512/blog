[![Build Status](https://travis-ci.org/phouse512/blog.svg?branch=master)](https://travis-ci.org/phouse512/blog)

#### blog

collection of personal thoughts related to technology, life, and other things.

###### deployment and operations

This blog is set up for continuous integration and deployment. It also has
a separate stage server hosted alongside http://phizzle.space 

When code is pushed/merged into the `stage` branch, the code is automatically
built and deployed to the stage server using my private jenkins box. Once
satisified with that, you can then merge code from `stage` to `master`, where
the code will be built and deployed directly to http://phizzle.space 

More on branching strategy for this:
- if working on more than one post at once, make sure that work is being done
  on new branches separate than that of `stage` and `master`.
- to test out a post on stage, commit your changes on your 'feature' branch,
  and then run `git checkout stage`. Next, run `git reset --hard
  <feature_branch>` to make stage look like your new post. Force push that to
  the remote stage branch to check it out.

