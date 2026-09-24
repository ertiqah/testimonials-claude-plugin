# testimonials.ltd for Claude Code

One install gives Claude Code both parts of the [testimonials.ltd](https://testimonials.ltd) Claude integration:

- **The connector** (`https://testimonials.ltd/mcp`): find, sort, approve, tag, feature, delete and import testimonials by chat.
- **The import skill**: brings your reviews from Trustpilot, G2, Capterra, Google, Yelp, the App Store and other review sites into testimonials.ltd, word for word, with names, ratings, dates, photos and a link back.

## Install

In your terminal:

```bash
claude plugin marketplace add ertiqah/testimonials-claude-plugin
claude plugin install testimonials@testimonials-ltd
```

Or inside Claude Code:

```
/plugin marketplace add ertiqah/testimonials-claude-plugin
/plugin install testimonials@testimonials-ltd
```

Then start Claude Code, run `/mcp`, pick `plugin:testimonials:testimonials` and sign in with your testimonials.ltd account.

Only want the connector? `claude mcp add --transport http testimonials https://testimonials.ltd/mcp`

Using Claude.ai or Claude Desktop instead? Add the connector under Settings > Connectors > Add custom connector, and upload the skill .zip under Settings > Capabilities. Step by step: https://testimonials.ltd/integrations/claude

## Update or remove

```bash
claude plugin marketplace update testimonials-ltd
claude plugin uninstall testimonials@testimonials-ltd
claude plugin marketplace remove testimonials-ltd
```

## Where the skill's words come from

`plugins/testimonials/skills/testimonials-import-reviews/SKILL.md` is a mirror of https://testimonials.ltd/skills/testimonials-import-reviews/SKILL.md, the same file that is inside the .zip download. A workflow in this repo copies it every few hours and on every push, so edit the site's copy, not this one.

## License

MIT
