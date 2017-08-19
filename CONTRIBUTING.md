# Contributing to wwkimball-dovecot

Contributors are welcome!  The rules for contributing to this project are really quite simple:

1. Put forth your best effort.  Your name will be attached to your changes, so do your very best.
2. Be "data-centric".  Devise how to use your new feature purely in YAML, then add the code that makes it happen.
3. Branch or fork, then use a Pull Request to have your changes reviewed.  Be sure to only open Pull Requests for completed work; no partial efforts.
4. Backward-compatibility adds too much cruft while Puppet major version support is too short-lived to bother.  Write for the current version of Puppet, whatever that is when you start adding code.
5. Try to add Unit and Acceptance tests where appropriate, but I won't rule out worthwhile contributions that omit such testing.  The reality is that awesome features can be added with as little as 10 minutes of effort but take well over an hour to vette out that feature with additional, comprehensive, automated tests, especially with rspec-puppet and Beaker (I'm sorry, but they _are_ hard to learn and a serious pain to set up the first few times).  That's a barrier to entry and a big workflow delay.  It's okay to come back to add tests later, or even to ask someone else to add them, especially if you aren't already fluent in rspec-puppet and Beaker.

Not every Pull Request will be accepted.  I'm ultimately responsible for the performance and quality of this code, so I will reject changes that don't meet my standards for either, which I reserve.  I will offer feedback via the Pull Request whenever I cannot simply accept the contributions.
