# TeamAsh

## Requirements
* [asdf](https://asdf-vm.com/)

## Setup
Run these commands in a terminal:
```
git clone git@github.com:launchscout/team_ash.git
cd team_ash
asdf install
mix setup
```

To start your Phoenix server:
```
mix phx.server
```
Or inside IEx with: `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Registering
With the server running visit: [`localhost:4000/register`](http://localhost:4000/register)

After registering, a local session is created authenticating and authorizing requests until the server is restarted or
browser cache cleared. See: `lib/team_ash_web/router.ex` for valid routes.

## Contributing
[How to Contribute to Open Source](https://opensource.guide/how-to-contribute/)
offer's the best advice.

### tl;dr
1. [Fork it](https://docs.github.com/en/github/getting-started-with-github/fork-a-repo)!
1. Create your feature branch: `git checkout -b cool-new-feature`
1. Commit your changes: `git commit -am 'Added a cool feature'`
1. Push to the branch: `git push origin cool-new-feature`
1. [Create new Pull Request](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request).