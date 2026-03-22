# Setting Up Google Cloud Credentials for Analytics Integration

This guide walks you through creating the credentials needed for Google Analytics + Google Search Console integration.

## Prerequisites

- A Google account with access to your website's Google Analytics and Search Console
- A Google Cloud project (will create one if you don't have it)

---

## Step 1: Create or Select a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click the project dropdown at the top
3. Click **"NEW PROJECT"**
4. Name it: `ai-performance-guardrails` (or any name)
5. Click **"CREATE"**
6. Wait for the project to be created, then select it from the dropdown

---

## Step 2: Enable Required APIs

In the same Google Cloud Console:

1. Click the **≡ menu** (top left) → **APIs & Services** → **Library**
2. Search for **"Google Analytics Data API"**
   - Click it
   - Click **"ENABLE"**
   - Wait for it to enable
3. Go back to **Library** (use the back button or menu)
4. Search for **"Google Search Console API"**
   - Click it
   - Click **"ENABLE"**
   - Wait for it to enable

---

## Step 3: Create a Service Account

1. In Google Cloud Console, click **≡ menu** → **APIs & Services** → **Credentials**
2. Click **"+ CREATE CREDENTIALS"** → **"Service Account"**
3. Fill in:
   - **Service account name**: `ai-guardrails`
   - **Description**: `Service account for AI Performance Guardrails`
   - Click **"CREATE AND CONTINUE"**
4. Grant roles (click **"CONTINUE"** on the next screen):
   - No need to grant roles here — we'll set them per-service
   - Click **"CONTINUE"** → **"DONE"**

---

## Step 4: Create and Download the JSON Key

1. In Google Cloud Console, go to **APIs & Services** → **Credentials**
2. Under **"Service Accounts"**, click the service account you just created (`ai-guardrails`)
3. Go to the **"KEYS"** tab
4. Click **"Add Key"** → **"Create new key"**
5. Choose **JSON** → **"CREATE"**
6. A file will download: `ai-guardrails-[random].json`
7. **Keep this file safe** — don't commit it to Git

---

## Step 5: Add Service Account to Google Analytics

1. Go to [Google Analytics](https://analytics.google.com/)
2. Click **Admin** (bottom left) → select your property
3. Under **Property Settings**, go to **"Property access management"**
4. Click **"+"** → **"Invite users"**
5. Paste the **service account email** from your JSON file:
   - Open the JSON file in a text editor
   - Copy the value of `"client_email"` (looks like: `ai-guardrails@project-id.iam.gserviceaccount.com`)
6. Assign role: **"Viewer"** (or **"Editor"** if you want the AI to make changes)
7. Click **"Invite"**

---

## Step 6: Add Service Account to Google Search Console

1. Go to [Google Search Console](https://search.google.com/search-console/)
2. Click your property (e.g., `https://www.example.com/`)
3. Click the **settings icon** (bottom left) → **Settings**
4. Go to **"Users and permissions"**
5. Click **"Add user"**
6. Paste the **service account email** (from Step 5)
7. Assign role: **"Full"** (Property Administrator)
8. Click **"Invite"**

---

## Step 7: Get Your GA4 Property ID

1. Go to [Google Analytics](https://analytics.google.com/)
2. Click **Admin** → select your property
3. Under **Property Settings**, find **"Property ID"**
   - It's a 10-digit number (e.g., `123456789`)
4. Copy it — you'll need this in `setup.sh`

---

## Step 8: Get Your GSC Site URL

1. Go to [Google Search Console](https://search.google.com/search-console/)
2. Find your property URL in the left sidebar
   - For URL properties: `https://www.example.com/`
   - For domain properties: `sc-domain:example.com`
3. Copy the exact URL — you'll need this in `setup.sh`

---

## Step 9: Run setup.sh

Now you have everything. Run:

```bash
bash setup.sh
```

When prompted:
- **GA Property ID**: Paste from Step 7
- **GSC Site URL**: Paste from Step 8
- **Service account JSON**: Paste the full path to the JSON file from Step 4
  - Example: `/Users/yourname/Downloads/ai-guardrails-abc123.json`

---

## Troubleshooting

### "The caller does not have permission"

This usually means the service account wasn't added to GA or GSC correctly.

**For Google Analytics:**
- Go back to GA Admin → Property → **Property access management**
- Verify the service account email is listed
- If not, add it again (Step 5)

**For Google Search Console:**
- Go to GSC → Settings → **Users and permissions**
- Verify the service account email is listed with "Full" access
- If not, add it again (Step 6)

### "Property ID not found"

Make sure you copied the GA4 Property ID (10 digits), not the old Tracking ID (starts with `UA-`).

**To verify:**
- Go to Google Analytics Admin → Property Settings
- Look for **"Property ID"** (should be numeric only)
- Don't use the Reporting ID or View ID

### "Site not found in Search Console"

Make sure the URL matches exactly:
- If it's a URL property: `https://www.example.com/` (with trailing slash)
- If it's a domain property: `sc-domain:example.com`

You can see the exact URL in the GSC sidebar — copy it character-for-character.

### "401 Unauthorized" after setup

The service account wasn't added to GA/GSC, or the role is too restrictive.

**Try:**
1. Remove the service account from GA/GSC (Step 5 & 6)
2. Wait 5 minutes
3. Re-add it with "Viewer" role for GA and "Full" role for GSC
4. Run `bash setup.sh` again

---

## Summary

Once `setup.sh` completes:
- ✅ Credentials are stored in `.env.analytics` (gitignored)
- ✅ MCP servers are installed (analytics-mcp, mcp-server-gsc)
- ✅ Claude Code is configured to use them
- ✅ The 3-phase performance loop is active

You can now ask Claude Code questions like:
- "What's our Core Web Vitals score this week?"
- "Which pages are slowest for real users?"
- "What's our search ranking for 'keyword'?"

And the automated 3-phase loop will validate code against real user data before every commit.
