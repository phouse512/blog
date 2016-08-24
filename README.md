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
