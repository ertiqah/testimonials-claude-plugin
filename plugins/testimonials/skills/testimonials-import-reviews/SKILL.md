---
name: testimonials-import-reviews
description: Import customer reviews from any public review page (Trustpilot, G2, Capterra, Google, Yelp, App Store, Google Play, Product Hunt, Shopify App Store, Chrome Web Store, Amazon, Tripadvisor, Clutch, Facebook and more) into testimonials.ltd: the full review history (every page, not just the first), word for word, with reviewer names, photos, ratings, dates and a link back to the original. Use when the user asks to import, pull, copy, sync or move reviews or testimonials from another site or a pasted page into testimonials.ltd. Needs the testimonials.ltd connector (https://testimonials.ltd/mcp).
---

# Import reviews into testimonials.ltd

You move a business's own public reviews from another platform into their testimonials.ltd account, where they can approve them and show them on widgets and their wall of love. You work through the testimonials.ltd connector tools, mainly `get_account_overview`, `import_from_url` (our server fetches every page itself) and `import_testimonials` (you send reviews you collected).

## Non-negotiable rules

1. **Exact words only.** Copy each review's text exactly as the customer wrote it: same spelling, punctuation, emoji, line breaks and language. Never summarise, shorten, translate, correct or "clean up" a review. If a review is longer than 5000 characters, skip it and say so; never cut it.
2. **Never import a truncated review.** If a review's text ends in "...", "…", "Show more", "Read more" or "See more", it was cut by the page or by your fetch tool. Get the full text first (see "Verbatim guard" below). If you cannot, leave that review out and say so.
3. **Never invent anything.** No made-up names, ratings, dates, titles or photos. If a field is not on the page, leave it out.
4. **Keep attribution.** Every review gets `source_platform` and, whenever the page has them, `source_review_id` and `source_url`. `source_url` must be the review's OWN link; if the site has no per-review link, leave it out (never put the page link on every review).
5. **Only the user's own business.** Import reviews about the user's own product, company or client (with the client's permission). If the page is clearly someone else's business, stop and ask.
6. **Preview before writing.** Always show a preview and get a yes before the real import.

## Step 1: Check the connection and pick the space

Call `get_account_overview`. If the tool is missing, tell the user to add the connector first, then sign in:
- Claude.ai or Claude Desktop: Settings > Connectors > Add custom connector > `https://testimonials.ltd/mcp`.
- Claude Code: `claude mcp add --transport http testimonials https://testimonials.ltd/mcp`, then run `/mcp` and sign in.

Setup guide: https://testimonials.ltd/integrations/claude

A space is one product or client site. If there is more than one space, ask which one the reviews belong to (show the names). Remember its `id`.

## Step 2: Get EVERY review

The goal is the user's whole review history from that page: every page, every review, with reviewer photos and review images. Never stop at the first page and never quietly import a sample. At the end you always report **"Imported N of M total reviews"**, where M is the total the site itself shows.

Ask for the review page link if the user has not given one.

### Route 1: let our server fetch everything (always try this first)

Call `import_from_url` with the link, the space and `"preview": true`. Nothing is imported yet.

- **It returns a preview** (source name, `site_total`, a sample): our server can read this site directly and will page through all of it and copy the photos. Show the user the source, the total and the sample, settle the choices in Step 4, then call `import_from_url` again with the same `url` (no `preview`) plus `status` (and `low_rating_status` / `min_rating` if chosen).
- A big import takes several calls. Each call works for about 40 seconds and returns `status`, a `progress` line and a `job_id`. While `status` is `"running"`, call `import_from_url` again with just `job_id` (wait `retry_after_seconds` first when given), and tell the user the progress line every few calls. Keep going until `status` is `"done"`. Do not ask the user whether to continue.
- **It returns `"status": "use_another_route"`**: our server cannot read this site (it refuses servers, needs a login, or its robots.txt says no). Follow the `routes` it lists, in order: usually Route 2 (you fetch the pages yourself), then Route 3 (the user's own Apify account), then Route 4 (the user pastes the page).

Direct server import works today for the Chrome Web Store and Shopify App Store (full history), and the App Store (the reviews Apple shows per storefront), plus anything the tool adds later, so always try it first.

### Route 2: you fetch the pages yourself

Most review sites that refuse our server let Claude's own fetcher in. Use your web fetch or browsing tool and **follow the pagination in the site notes until you have every page**:

1. Fetch page 1 and write down the site's total (M), for example "351 reviews" or "Showing 1-25 of 2,825".
2. Fetch the next page, and the next, until a page has no new reviews or you reach M. Import as you go: after every page or two, send those reviews to `import_testimonials` (Step 5), so nothing is lost if the chat is interrupted. Re-sending a review is safe: duplicates are skipped.
3. **If your fetch stops early** (403, a captcha, a login page, or page N suddenly shows page 1 again) while you are still short of M: do not stop there. Tell the user how many you have, then offer Route 3 (their Apify token: `import_from_url` fetches the rest, with photos, and skips the ones you already imported) or Route 4 (they paste the remaining pages).
4. If you are in Claude.ai and cannot open page 2 or later, ask the user to paste those page links into the chat.

Things to know about fetch tools:
- They return the page as text, not raw HTML. Expect **few or no reviewer photo URLs**. See the site notes for how to get photos on each site.
- Some fetch tools pass the page through a summariser. Ask for the reviews **verbatim**, and do not trust a summary for star ratings or section labels. Read the star rating from the review itself (for example "Rated 5 out of 5", "5 star rating", "5 of 5 bubbles"), never from reviewer badges or counts.

**Verbatim guard.** If a fetched review ends in "...", "…", "Show more", "Read more" or "See more", treat it as truncated. Re-fetch asking for the exact full text of that review, or ask the user for View Source, where the full text usually sits in the page's embedded data. Never import the cut version.

### Route 3: the user's own Apify account (for the rest, or for sites that block everything)

When our server and your fetch cannot get everything (Facebook, Amazon, G2 beyond page 1, Trustpilot beyond what its filters show, any site that starts refusing mid-way), offer this. Only offer it; never require it.

1. Explain: Apify is a scraping service; the run happens on the user's own Apify account and is billed to it (usually cents to a few dollars for a few hundred reviews). They copy their API token from apify.com > Settings > API & Integrations.
2. Call `import_from_url` with the page `url` and `apify_token`. Our server picks the right actor, runs it, imports every review with photos, and returns progress like Route 1. On every follow-up call pass `job_id` **and** `apify_token` again (the token is never stored).
3. Reviews you already imported by Route 2 are skipped as duplicates, so the count still adds up.

### Route 4: the user gives you the page

If nothing above works, ask the user to do ONE of these and send you the result. Give them the exact steps for their browser, and pick the option that fits the site:

- **Copy the visible text (easiest, works on every site).** Open the review page (sign in first on Facebook and Amazon), load every review (scroll, click "Load more" or "See all reviews" until the end), and click every "More" / "Read more" so each review shows in full. Then press Ctrl+A and Ctrl+C (Cmd+A, Cmd+C on Mac) and paste here. It does not carry reviewer photos or review ids. For long histories, ask for it in parts (one page or a few hundred reviews at a time) until you have all of them.
- **Copy the page source (best for photos).** Press Ctrl+U (Cmd+Option+U on Mac) to open View Source, then Ctrl+A and Ctrl+C, and paste it here. It holds the reviews, with photo links, on Trustpilot, Product Hunt, Shopify App Store, Tripadvisor, Clutch, Capterra, the App Store and Chrome Web Store (first 10). It does **not** work on Google Maps, Google Play, Facebook or Amazon: those load reviews with scripts or behind a login, so the source has none. One page of reviews per paste.
- **Save the page (long pages, keeps photos).** After loading and expanding every review, press Ctrl+S (Cmd+S on Mac), choose **"Webpage, Complete"**, and attach only the saved `.html` file here (ignore the folder next to it). "Webpage, HTML only" saves the page as it was before scrolling, so reviews loaded by scrolling or "Load more" are missing. If the chat will not accept `.html`, rename it to `.txt` first.
- **Copy the rendered page (photos, harder).** After everything is loaded, open DevTools (F12 or Cmd+Option+I), go to Elements, right-click the `<html>` line, choose Copy > Copy outerHTML, and paste it here. Offer this only when the user wants photos from a site where View Source is empty.

Keep asking for the next part until the count reaches the site's total, or the user says that is enough.

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
  "source_url": "https://... this review's own link (leave out if it has none)",
  "source_review_id": "the platform's id for this review",
  "review_date": "2025-03-14",
  "images": ["https://... photos attached to the review"]
}
```

Notes:
- `rating`: the star count. Halves are fine (4.5 is rounded). For sites scored out of 10, send the score and `"rating_scale": 10`.
- `source_platform`: one of trustpilot, g2, capterra, google, yelp, appstore, playstore, producthunt, facebook, tripadvisor, amazon, shopify, twitter, linkedin, reddit, youtube, instagram, appsumo, chrome, clutch, other.
- `author_avatar_url`: leave it out when the site shows a generic placeholder (initials, silhouette, default avatar) instead of a real photo. Use the largest real image URL on the page.
- Multi-part reviews (G2 "What do you like best?", Capterra "Overall" / "Pros" / "Cons"): put the parts in `text` exactly as written, each part on its own paragraph starting with the site's own question or label, for example `What do you like best?\n<answer>\n\nWhat do you dislike?\n<answer>`. Ask the user whether they want the "dislike" or "cons" part included; if they say no, include only the positive parts, still word for word.
- Owner replies, "helpful" counts and ads are not part of the review. Leave them out.
- Dates: convert to `YYYY-MM-DD` (or full ISO). "3 days ago" style dates: work out the date from today, or leave it out if unsure. Month-only dates ("Aug 2026"): use the first of the month, or leave it out if the user prefers.

### Site notes

"Server" means `import_from_url` does the whole job itself (Route 1). The rest are Route 2 with the pagination shown, then Route 3 or 4 for whatever is left.

- **Chrome Web Store**: server. Full history in every language, with the untruncated text and reviewer photos. The store's count is of star ratings, and many ratings have no written review, so N is usually below M: say so.
- **Shopify App Store**: server. Every page. Reviewers are stores (name plus country), so there are no personal photos.
- **App Store**: server, but Apple only publishes about 10 reviews per country on its public pages (its review feed and API ask bots to stay out), so the server collects those from every storefront. Apple's count is of star ratings, most without text. For the full history: if the user owns the app, App Store Connect has every review (Ratings and Reviews); ask them to paste or export them, or use Route 3. Apple shows no reviewer photos.
- **Google Play**: our server may not read Play's review list (robots.txt), and a fetched page holds only 3 reviews. If the user owns the app, Play Console > Download reports > Reviews gives CSV files with every review (text, stars, dates): ask them to attach them. Otherwise Route 4 (open "See all reviews", scroll to the end, copy the visible text) or Route 3 (with reviewer photos). The count includes star-only ratings without text.
- **Google Maps / Business Profile**: Google's review list is off limits to our server and to fetch tools (robots.txt, and it is a JavaScript app). Route 4: open the place, click Reviews, sort by Newest, scroll to the end, click every "More", then copy; or Route 3, which also brings reviewer photos and review photos. Relative dates ("2 months ago"): convert from today or leave them out.
- **Trustpilot**: Route 2. Fetch `https://www.trustpilot.com/review/<domain>?languages=all&sort=recency&page=N`, 20 per page; `languages=all` includes every language. Signed-out visitors get **at most 10 pages (200 reviews) per view**: page 11 redirects to a login. Compare the reviews you have with the total in the page header. If you are short (more than 200 reviews, or the list simply shows fewer than the header), also fetch each star level, `&stars=5` ... `&stars=1`, **all 10 pages of each** (or until a page has no reviews at all): early pages of a star view can be all repeats while later pages still hold new ones, so do not stop at a page of repeats. Duplicates are skipped on import. If one star level alone has more than 200, use Route 3 for the rest. The full text and `consumer.imageUrl` (the reviewer photo) sit in the page's `__NEXT_DATA__` data when your tool shows it; otherwise, when a reviewer link like `/users/<id>` is visible, use `https://user-images.trustpilot.com/<id>/73x73.png` (missing photos are dropped automatically). Review link: `https://www.trustpilot.com/reviews/<review id>`.
- **G2**: refuses scripted fetches, often even page 1 (403). Use Route 3, or Route 4 page by page. No photos.
- **Capterra**: Route 2, returns clean Markdown. `?page=N`, 25 per page ("Showing 1-25 of N"). Each review is an unlabelled first paragraph followed by "Pros" and "Cons" (and sometimes "Alternatives considered", "Switched from", "Reason for choosing"): keep the parts and the site's labels exactly; ask the user whether to include Cons and the extra sections. There are no review ids or review links, so leave `source_url` and `source_review_id` out. No photos.
- **Yelp**: Route 2. `?start=0`, `?start=10`, `?start=20` ... 10 per page. Fetch tools often lose each review's star rating; the only "N star rating" text left may belong to Yelp's own "write a review" widget, so never take the rating from there. If a review's stars are not clearly attached to it, ask for View Source or the copied visible text, or import without a rating only if the user agrees. Reviewer photos are on `yelpcdn.com`. Yelp hides "not currently recommended" reviews from its list and its count.
- **Product Hunt**: Route 2. `https://www.producthunt.com/products/<product>/reviews?page=N`. The total mixes regular reviews (10 per page) and reviews by makers of other products (3 per page); the maker reviews run on for more pages after the regular list ends, so keep going until a page has neither. Fetched text may cut reviews short and drop the stars; View Source has JSON-LD `Product.review[]` with the full `reviewBody`, `reviewRating.ratingValue`, `datePublished`, `author.name`, `author.image` (real photo). Reviews without text are star-only: import them only with a rating. Prefer View Source when the user wants photos.
- **Tripadvisor**: Route 2. Pages via `...-Reviews-or10-...html`, `-or20-`, 10 per page. The full text is in the page even where it shows "Read more". Rating is "N of 5 bubbles". Dates are month only and may carry the trip type ("Jan 2026 • Friends"): keep only the date (see Dates). Drop `default-avatar` placeholder images. Review photos are there too: add them to `images`.
- **Clutch**: Route 2. `https://clutch.co/profile/<company>`, then `?page=2`, `?page=3` ... 10 per page; page 1 also has one "Featured Review" that is not repeated later. Use the reviewer's quoted feedback plus the "Results & Feedback" answers as `text`, verbatim, each on its own paragraph with the site's labels. Ratings can be halves (4.5). The reviewer is often a role and company (for example "COO, Electragram") or "Anonymous": put the role in `author_title` and the company in `author_company`, and use the name shown (or the role when it says Anonymous) as `author_name`. Use the review's `review-<id>` anchor as `source_review_id`. `source_platform`: `clutch`. No photos.
- **Facebook**: login wall. Route 3, or Route 4 (the signed-in user copies the visible text from the page's Reviews tab).
- **Amazon**: review pages need sign-in. Route 3, or Route 4 (the signed-in user copies the visible text of each reviews page). Only for the user's own product.
- **Posts on X, LinkedIn, Reddit, YouTube comments**: the user can paste the post text and link; set `source_platform` accordingly.

## Step 4: Preview and choose

Show a compact table: number, reviewer, stars, date, first 80 characters of text, photo yes/no. Then state the totals (for example "38 reviews: 29 five-star, 6 four-star, 3 at three stars or below"). List any reviews you left out (truncated, too long) and why.

Ask the user (in one message, with a sensible default):
- Which to import (default: all; common choice: 4 and 5 stars only).
- Whether they go live now (`approved`) or into their approval queue (`pending`). Default: live for 4 to 5 stars, approval queue for 3 stars or below.
- For multi-part reviews, whether to include the negative part.
- If no photos came through and the site has them, whether they want to send View Source so photos are included.

For `import_from_url`, pass the choices as `status` (for example `approved`), `low_rating_status` (for example `pending` for 1 to 3 stars) and `min_rating` (for example 4 to leave out 1 to 3 stars).

## Step 5: Import in batches (Routes 2 and 4)

`import_from_url` imports on its own; this step is for reviews you collected yourself.

1. Split into batches of at most 50 reviews.
2. For the first batch, call `import_testimonials` with `space_id`, `reviews`, `status` and `"dry_run": true`. Check the result: fix `invalid` rows if you can (never by changing the customer's words), and report `duplicates` (reviews already in the space are skipped automatically, so re-running an import is safe).
3. Call `import_testimonials` again for each batch with `"dry_run": false`. Per-review `status` overrides the batch default (use it for the 4-to-5 live, 3-and-below pending split).
4. Keep `copy_images` on (the default): reviewer photos and review images are copied to the user's own storage so they keep working if the original site changes. If some stayed as original links, mention it.

## Step 6: Report and suggest next steps

Report in one line first: **"Imported N of M total reviews from <site>"** (N = created plus the ones already in the space; M = the site's own total). If N is below M, say why in plain words (for example: the site counts star-only ratings that have no text, hides some reviews from its public list, or the rest need Route 3 or 4, and offer that). Then give created, duplicates skipped, invalid and why, photos copied, and anything over the plan limit. Then offer useful follow-ups with the connector tools:
- `get_share_links` for their wall of love link and widget embed code.
- `feature_testimonials` to star the strongest reviews and pin them to the top of a widget.
- `tag_testimonials` to label them (for example by topic or by platform).
- `moderate_testimonials` to approve the ones sent to the queue.

If something goes wrong mid-way, say exactly which batches finished. Running the same import again is safe because duplicates are skipped.
