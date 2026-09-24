---
name: testimonials-import-reviews
description: Import customer reviews from any public review page (Trustpilot, G2, Capterra, Google, Yelp, App Store, Google Play, Product Hunt, Shopify App Store, Chrome Web Store, Amazon, Tripadvisor, Clutch, Facebook and more) into testimonials.ltd, word for word, with reviewer names, photos, ratings, dates and a link back to the original. Use when the user asks to import, pull, copy, sync or move reviews or testimonials from another site or a pasted page into testimonials.ltd. Needs the testimonials.ltd connector (https://testimonials.ltd/mcp).
---

# Import reviews into testimonials.ltd

You move a business's own public reviews from another platform into their testimonials.ltd account, where they can approve them and show them on widgets and their wall of love. You work through the testimonials.ltd connector tools, mainly `get_account_overview` and `import_testimonials`.

## Non-negotiable rules

1. **Exact words only.** Copy each review's text exactly as the customer wrote it: same spelling, punctuation, emoji, line breaks and language. Never summarise, shorten, translate, correct or "clean up" a review. If a review is longer than 5000 characters, skip it and say so; never cut it.
2. **Never import a truncated review.** If a review's text ends in "...", "…", "Show more", "Read more" or "See more", it was cut by the page or by your fetch tool. Get the full text first (see "Verbatim guard" below). If you cannot, leave that review out and say so.
3. **Never invent anything.** No made-up names, ratings, dates, titles or photos. If a field is not on the page, leave it out.
4. **Keep attribution.** Every review gets `source_platform` and, whenever the page has it, `source_url` (the review's own link, or the page link) and `source_review_id`.
5. **Only the user's own business.** Import reviews about the user's own product, company or client (with the client's permission). If the page is clearly someone else's business, stop and ask.
6. **Preview before writing.** Always show a preview and get a yes before the real import.

## Step 1: Check the connection and pick the space

Call `get_account_overview`. If the tool is missing, tell the user to add the connector first, then sign in:
- Claude.ai or Claude Desktop: Settings > Connectors > Add custom connector > `https://testimonials.ltd/mcp`.
- Claude Code: `claude mcp add --transport http testimonials https://testimonials.ltd/mcp`, then run `/mcp` and sign in.

Setup guide: https://testimonials.ltd/integrations/claude

A space is one product or client site. If there is more than one space, ask which one the reviews belong to (show the names). Remember its `id`.

## Step 2: Get the reviews

Ask for the review page link if the user has not given one. Look up the platform in the site notes below, then use the route they name. When in doubt, try these routes in order and stop at the first that gives you the reviews.

### Route A: fetch the page yourself

Most review sites let Claude's own fetcher in, even though they block ordinary scripts. **Always try the fetch first on every platform except Google Maps, Google Play, Facebook and Amazon** (for those four, go straight to Route B's "copy the visible text", or Route C).

Use your web fetch or browsing tool on the link and follow pagination (see the site notes) until you have every review or the user's requested number.

Things to know about fetch tools:
- They return the page as text, not raw HTML. Expect **no reviewer photo URLs** and no JSON blobs (`__NEXT_DATA__`, JSON-LD). If the user wants reviewer photos, finish the preview first, then ask for View Source (Route B) for the pages whose photos they want.
- Some fetch tools pass the page through a summariser. Ask for the reviews **verbatim**, and do not trust a summary for star ratings or section labels. Read the star rating from the review itself (for example "Rated 5 out of 5", "5 star rating", "5 of 5 bubbles"), never from reviewer badges or counts.
- If you are in Claude.ai and cannot open page 2 or later, ask the user to paste those page links into the chat.

**Verbatim guard.** If a fetched review ends in "...", "…", "Show more", "Read more" or "See more", treat it as truncated. Re-fetch asking for the exact full text of that review, or ask the user for View Source, where the full text usually sits in the page's embedded data. Never import the cut version. (Chrome Web Store and Shopify App Store often hit this.)

### Route B: the user gives you the page

If the fetch is blocked (403, captcha, login wall, "enable JavaScript"), or the reviews are missing from what you got, ask the user to do ONE of these and send you the result. Give them the exact steps for their browser, and pick the option that fits the site:

- **Copy the visible text (easiest, works on every site).** Open the review page (sign in first on Facebook and Amazon), load every review they want (scroll, click "Load more" or "See all reviews"), and click every "More" / "Read more" so each review shows in full. Then press Ctrl+A and Ctrl+C (Cmd+A, Cmd+C on Mac) and paste here. This is the default for Google Maps, Google Play, Facebook and Amazon. It does not carry reviewer photos or review ids.
- **Copy the page source (best for photos).** Press Ctrl+U (Cmd+Option+U on Mac) to open View Source, then Ctrl+A and Ctrl+C, and paste it here. It holds the reviews, with photo links, on Trustpilot, Product Hunt, Shopify App Store, Tripadvisor, Clutch, Capterra, the App Store and Chrome Web Store (first 10). It does **not** work on Google Maps, Google Play, Facebook or Amazon: those load reviews with scripts or behind a login, so the source has none.
- **Save the page (long pages, keeps photos).** After loading and expanding every review, press Ctrl+S (Cmd+S on Mac), choose **"Webpage, Complete"**, and attach only the saved `.html` file here (ignore the folder next to it). "Webpage, HTML only" saves the page as it was before scrolling, so reviews loaded by scrolling or "Load more" are missing. If the chat will not accept `.html`, rename it to `.txt` first. A saved Google Maps page can be several MB: ask for it in parts.
- **Copy the rendered page (photos, harder).** After everything is loaded, open DevTools (F12 or Cmd+Option+I), go to Elements, right-click the `<html>` line, choose Copy > Copy outerHTML, and paste it here. Offer this only when the user wants photos from a site where View Source is empty.

For very large pages, ask them to send it in parts (for example one page of reviews at a time).

### Route C (optional): the user's own Apify account

For big imports (hundreds of reviews) or the sites that need a login or run on scripts (Google Maps, Google Play, Facebook, Amazon, G2 beyond page 1), the user can use their own Apify account. Only offer this; never require it. Runs are billed to the user's Apify account; say so.

Use the actor for the platform (check its input schema before running, since actors change):

| Platform | Apify actor |
|---|---|
| Google Maps | `compass/Google-Maps-Reviews-Scraper` |
| Amazon | `junglee/amazon-reviews-scraper` |
| Facebook | `apify/facebook-reviews-scraper` |
| Google Play | `neatrat/google-play-store-reviews-scraper` |
| Tripadvisor | `maxcopell/tripadvisor` |
| Yelp | `tri_angle/yelp-review-scraper` |
| G2 | `zen-studio/g2-reviews-scraper` |
| Capterra | `zen-studio/capterra-reviews-scraper` |
| G2, Capterra and Trustpilot | `zen-studio/software-review-scraper` |
| Trustpilot | `memo23/trustpilot-scraper-ppe` |
| Clutch | `epctex/clutchco-scraper` |
| Product Hunt | `memo23/producthunt-scraper` |
| Chrome Web Store | `automation-lab/chrome-web-store-reviews-scraper` |
| App Store | not needed: use the public feed in the site notes |

- If an Apify connector is available in this chat, use it: tell the user which actor you picked, run it with the page link and read the dataset items.
- If you can run shell commands (Claude Code), use the Apify API with the token the user gives you. Read the input schema with `curl -s "https://api.apify.com/v2/acts/<username>~<actor-name>?token=$APIFY_TOKEN"`, then run it with `curl -s -X POST "https://api.apify.com/v2/acts/<username>~<actor-name>/run-sync-get-dataset-items?token=$APIFY_TOKEN" -H "Content-Type: application/json" -d '<actor input JSON>'`. Keep the token in an environment variable, never echo it, and never pass it to testimonials.ltd.
- Apify results still go through every rule above: exact words, no truncated text, preview first.

## Step 3: Extract each review into this shape

```json
{
  "text": "exact review body",
  "rating": 5,
  "rating_scale": 5,
  "title": "review headline, if any",
  "author_name": "as shown",
  "author_title": "job title or role, if shown",
  "author_company": "company, if shown",
  "author_avatar_url": "https://... reviewer photo",
  "author_profile_url": "https://... reviewer profile, if shown",
  "source_platform": "trustpilot",
  "source_url": "https://... link to this review (or the page)",
  "source_review_id": "the platform's id for this review",
  "review_date": "2025-03-14",
  "images": ["https://... photos attached to the review"]
}
```

Notes:
- `rating`: the star count. Halves are fine (4.5 is rounded). For sites scored out of 10, send the score and `"rating_scale": 10`.
- `source_platform`: one of trustpilot, g2, capterra, google, yelp, appstore, playstore, producthunt, facebook, tripadvisor, amazon, shopify, twitter, linkedin, reddit, youtube, instagram, appsumo, chrome, other. Use `other` for Clutch.
- `author_avatar_url`: leave it out when the site shows a generic placeholder (initials, silhouette, default avatar) instead of a real photo. Use the largest real image URL on the page.
- Multi-part reviews (G2 "What do you like best?", Capterra "Overall" / "Pros" / "Cons"): put the parts in `text` exactly as written, each part on its own paragraph starting with the site's own question or label, for example `What do you like best?\n<answer>\n\nWhat do you dislike?\n<answer>`. Ask the user whether they want the "dislike" or "cons" part included; if they say no, include only the positive parts, still word for word.
- Owner replies, "helpful" counts and ads are not part of the review. Leave them out.
- Dates: convert to `YYYY-MM-DD` (or full ISO). "3 days ago" style dates: work out the date from today, or leave it out if unsure. Month-only dates ("Aug 2026"): use the first of the month, or leave it out if the user prefers.

### Site notes

- **Trustpilot**: fetch works. `https://www.trustpilot.com/review/<domain>?page=N`, 20 per page; add `&stars=5` to filter. Fetched text has no photos. View Source has a `<script id="__NEXT_DATA__">` blob with each review's id, title, text, rating, published date, `consumer.displayName` and `consumer.imageUrl` (an empty string means no photo). The `title` there can be cut with an ellipsis; the body is in `text`. Review link: `https://www.trustpilot.com/reviews/<id>`.
- **G2**: fetch works for the **first page only**; `?page=2` is blocked. For more, the user sends each further page by Route B, or uses Apify. No photos.
- **Capterra**: fetch works and returns clean Markdown. `?page=N`, 25 per page. Parts are Overall / Pros / Cons (keep the site's labels exactly). No photos.
- **Yelp**: fetch works. `?start=10`, `?start=20`, 10 per page. Take the star rating from the review ("N star rating"), not from reviewer badges such as "Elite" or review counts. Photos are on `yelpcdn.com`.
- **Google Maps / Business Profile**: cannot be fetched (it is a JavaScript app, and View Source is empty). Ask for the copied visible text: open the place, click Reviews, sort by Newest, scroll until enough load, click every "More", then copy. Or Apify `compass/Google-Maps-Reviews-Scraper`. Dates are relative ("2 months ago"): convert from today or leave them out. Visible text has no photos; a "Webpage, Complete" save or Copy outerHTML keeps them.
- **Google Play**: the page holds only 3 reviews. Ask for the visible text after opening "See all reviews" and scrolling. If the user owns the app, Play Console > Download reports > Reviews gives monthly CSV files with every review (text, stars, dates, no photos). Or Apify.
- **App Store**: use Apple's public feed instead of the web page: `https://itunes.apple.com/<country>/rss/customerreviews/page=<1-10>/id=<app id>/sortby=mostrecent/json` (the app id is the number after `id` in the App Store link). 50 per page, at most 10 pages (500 reviews) per country; page 11 returns an error. Reviews are per country, so repeat with other country codes (`us`, `gb`, `de`...) for other storefronts. Each `feed.entry[]` has `author.name.label`, `im:rating.label`, `title.label`, `content.label`, `id.label`, `updated.label`. No photos (Apple does not show them).
- **Product Hunt**: fetch works. `https://www.producthunt.com/products/<product>/reviews?page=N`, 10 per page. Fetched text may cut reviews short and drop the stars; View Source has JSON-LD `Product.review[]` with the full `reviewBody`, `reviewRating.ratingValue`, `datePublished`, `author.name`, `author.image` (real photo), `positiveNotes` / `negativeNotes`. Prefer View Source.
- **Tripadvisor**: fetch works. Pages via `...-Reviews-or10-...html`, `-or20-`, 10 per page. Rating is "N of 5 bubbles". Dates are month only (see Dates). Drop `default-avatar` placeholder images.
- **Clutch**: fetch works, and one fetch usually returns every review. Use the reviewer's quoted feedback plus the "Results & Feedback" answers as `text`, verbatim, each on its own paragraph with the site's labels. The reviewer is often a role and company (for example "COO, Electragram") rather than a name: put the role in `author_title` and the company in `author_company`, and use what the page shows as `author_name` (or the role if no name is given). `source_platform`: `other`. No photos.
- **Shopify App Store**: fetch works. `https://apps.shopify.com/<app>/reviews?page=N`, 10 per page. The full text is in the page even behind "Show more", so apply the verbatim guard if a fetched review looks cut. Reviewers are stores (store name plus country); no personal photos.
- **Chrome Web Store**: fetch gives the first 10 reviews, but the visible text is cut with "..." and "Show more". The full text is only in View Source (embedded `AF_initDataCallback` JSON). Photos are on `lh3.googleusercontent.com` (swap `=s48` for `=s96` for a larger one). More than 10: visible text after clicking "Load more" and expanding each review, or Apify.
- **Facebook**: login wall, cannot be fetched. Ask the signed-in user to open the page's Reviews tab, scroll, expand each review and copy the visible text; or Apify `apify/facebook-reviews-scraper`.
- **Amazon**: review pages need sign-in, so they cannot be fetched. Ask the signed-in user to copy the visible text from the product's reviews page; or Apify `junglee/amazon-reviews-scraper`. Only for the user's own product.
- **Posts on X, LinkedIn, Reddit, YouTube comments**: the user can paste the post text and link; set `source_platform` accordingly.

## Step 4: Preview and choose

Show a compact table: number, reviewer, stars, date, first 80 characters of text, photo yes/no. Then state the totals (for example "38 reviews: 29 five-star, 6 four-star, 3 at three stars or below"). List any reviews you left out (truncated, too long) and why.

Ask the user (in one message, with a sensible default):
- Which to import (default: all; common choice: 4 and 5 stars only).
- Whether they go live now (`approved`) or into their approval queue (`pending`). Default: live for 4 to 5 stars, approval queue for 3 stars or below.
- For multi-part reviews, whether to include the negative part.
- If no photos came through and the site has them, whether they want to send View Source so photos are included.

## Step 5: Import in batches

1. Split into batches of at most 50 reviews.
2. For the first batch, call `import_testimonials` with `space_id`, `reviews`, `status` and `"dry_run": true`. Check the result: fix `invalid` rows if you can (never by changing the customer's words), and report `duplicates` (reviews already in the space are skipped automatically, so re-running an import is safe).
3. Call `import_testimonials` again for each batch with `"dry_run": false`. Per-review `status` overrides the batch default (use it for the 4-to-5 live, 3-and-below pending split).
4. Keep `copy_images` on (the default): reviewer photos and review images are copied to the user's own storage so they keep working if the original site changes. If some stayed as original links, mention it.

## Step 6: Report and suggest next steps

Report created, duplicates skipped, invalid and why, and anything over the plan limit. Then offer useful follow-ups with the connector tools:
- `get_share_links` for their wall of love link and widget embed code.
- `feature_testimonials` to star the strongest reviews and pin them to the top of a widget.
- `tag_testimonials` to label them (for example by topic or by platform).
- `moderate_testimonials` to approve the ones sent to the queue.

If something goes wrong mid-way, say exactly which batches finished. Running the same import again is safe because duplicates are skipped.
