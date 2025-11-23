# 🚀 Setup Guide - Application Center

Complete step-by-step guide to get your Application Center up and running.

## 📋 Prerequisites

- PHP 8.0 or higher
- Web server (Apache/Nginx) with PHP support
- SSL certificate (HTTPS required for Roblox)
- Roblox group ownership or admin access
- Featherless AI account

## 🔧 Installation

### Step 1: Upload Files

Upload all files to your web server:

```
/home/YourUser/web/your-domain.com/
├── .env                  # Copy from .env.example
├── public_html/          # Web root
├── data/                 # Storage
├── src/                  # Backend
└── roblox/              # Roblox scripts
```

**Important**: Only `public_html` should be publicly accessible!

### Step 2: Configure Web Server

#### Apache (.htaccess already configured)

Ensure mod_rewrite is enabled:
```bash
sudo a2enmod rewrite
sudo systemctl restart apache2
```

Document root should point to `public_html`:
```apache
<VirtualHost *:443>
    ServerName your-domain.com
    DocumentRoot /path/to/your-domain.com/public_html
    
    <Directory /path/to/your-domain.com/public_html>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

#### Nginx

```nginx
server {
    listen 443 ssl;
    server_name your-domain.com;
    
    root /path/to/your-domain.com/public_html;
    index index.php;
    
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.0-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

### Step 3: Set Permissions

```bash
# Make directories writable
chmod 755 data
chmod 755 data/apps
chmod 755 data/submissions
chmod 755 data/creators

# Protect .env
chmod 600 .env
```

### Step 4: Configure .env

Copy the example file:
```bash
cp .env.example .env
```

Edit `.env` with your values:
```env
ROBLOX_API_KEY=your_roblox_api_key_here
FEATHERLESS_API_KEY=rc_your_featherless_api_key_here
FEATHERLESS_MODEL=google/gemma-3-27b-it
FEATHERLESS_BASE_URL=https://api.featherless.ai/v1
APP_DEBUG=false
APP_URL=https://your-domain.com
```

## 🔑 Getting API Keys

### Roblox API Key

1. Go to [Roblox Creator Hub](https://create.roblox.com/credentials)
2. Click **"Create API Key"**
3. Configure:
   - **Name**: Application Center
   - **Scopes**: 
     - ✅ `group:read`
     - ✅ `group:write`
     - ✅ `user:read`
4. **Security**:
   - Add your server IP to allowed IPs (optional but recommended)
   - Set expiration date
5. Copy the API key and add to `.env`

**Important**: Keep this key secure! It has group management permissions.

### Featherless AI API Key

1. Visit [Featherless.ai](https://featherless.ai)
2. Sign up for an account
3. Navigate to **API Keys** section
4. Click **"Create New Key"**
5. Copy the key (starts with `rc_`)
6. Add to `.env`

**Pricing**: Check current rates at Featherless.ai. Budget ~$0.001-0.01 per short answer graded.

## 🎮 Roblox Setup

### Step 1: Enable HTTP Requests

In Roblox Studio:
1. Go to **Home** → **Game Settings**
2. Navigate to **Security** tab
3. Enable **"Allow HTTP Requests"**
4. Click **Save**

### Step 2: Insert Scripts

1. Open your Roblox game in Studio
2. Insert `AppCenterClient.lua`:
   - Right-click **ServerScriptService**
   - Insert **ModuleScript**
   - Name it `AppCenterClient`
   - Paste the contents of `roblox/AppCenterClient.lua`

3. Insert setup script:
   - Right-click **ServerScriptService**
   - Insert **Script**
   - Name it `ApplicationSetup`
   - Paste the contents of `roblox/ExampleSetup.lua`

### Step 3: Configure Script

Edit the setup script:
```lua
local APP_ID = "your_app_id_here"  -- From builder
local SERVER_URL = "https://your-domain.com"
```

### Step 4: Test

1. Play the game in Studio
2. Find the red "ApplicationPart"
3. Click to open the application
4. Fill out and submit
5. Check your web dashboard for submissions

## 🎨 Creating Your First Application

### Step 1: Access Builder

Navigate to: `https://your-domain.com/`

### Step 2: Create Application

1. Click **"Create Your First Application"**
2. Fill in basic info:
   - **Name**: Staff Application
   - **Description**: Apply to join our staff team
   - **Group ID**: Your Roblox group ID (find in URL)
   - **Target Role**: Format: `groups/YOUR_GROUP_ID/roles/ROLE_ID`
   - **Pass Score**: 75 (recommended)

### Step 3: Add Questions

Click **"Add Question"** and create:

**Question 1 - Multiple Choice:**
- Type: Multiple Choice
- Text: "Why do you want to join our staff team?"
- Points: 10
- Options: Add 4 options, mark correct one

**Question 2 - Short Answer:**
- Type: Short Answer
- Text: "Describe your previous experience in Roblox groups"
- Points: 25
- Max Length: 300
- Grading Criteria: "Look for specific examples and relevant experience"

**Question 3 - Checkboxes:**
- Type: Checkboxes
- Text: "Which staff duties can you handle?"
- Points: 20
- Options: Add options, mark multiple as correct

### Step 4: Customize Style

- **Primary Color**: Choose your brand color
- **Secondary Color**: Complementary color

### Step 5: Save

Click **"Save"** - this generates the `.astappcnt` file

### Step 6: Get Application ID

The ID will be shown after saving. Use this in your Roblox script.

## 🔍 Finding Group and Role IDs

### Group ID

1. Go to your group page on Roblox
2. Look at the URL: `roblox.com/groups/GROUP_ID/...`
3. Copy the number

### Role ID

Method 1 - Using Roblox Cloud API:
```bash
curl -H "x-api-key: YOUR_API_KEY" \
  https://apis.roblox.com/cloud/v2/groups/GROUP_ID/roles
```

Method 2 - Browser Console:
1. Go to group page
2. Open browser console (F12)
3. Paste:
```javascript
fetch(`https://groups.roblox.com/v1/groups/GROUP_ID/roles`)
  .then(r => r.json())
  .then(d => console.table(d.roles.map(r => ({name: r.name, id: r.id}))))
```

The format should be: `groups/GROUP_ID/roles/ROLE_ID`

Example: `groups/123456/roles/99999999`

## ✅ Testing

### Test Application Submission

1. Open Roblox game
2. Trigger application prompt
3. Fill out form
4. Submit
5. Check response (passed/failed)

### Test Auto-Promotion

1. Submit a passing application
2. Check if role was updated in group
3. Verify in Roblox group members

### Test Grading

1. Submit application with short answers
2. Check `data/submissions/` for result
3. Verify AI feedback is reasonable
4. Adjust grading criteria if needed

## 🐛 Troubleshooting

### "Failed to load application config"

**Causes:**
- Incorrect APP_ID
- HTTP requests not enabled
- Server URL wrong
- Server not accessible

**Fix:**
1. Verify APP_ID matches saved application
2. Enable HTTP requests in game settings
3. Test server URL in browser
4. Check firewall/SSL settings

### "Grading failed"

**Causes:**
- Invalid Featherless API key
- Out of API credits
- Network issues

**Fix:**
1. Verify API key in `.env`
2. Check Featherless account balance
3. Check API logs for errors
4. Reduce short answer questions

### "Promotion failed"

**Causes:**
- Invalid Roblox API key
- User not in group
- Incorrect role path
- Insufficient permissions

**Fix:**
1. Verify API key has group permissions
2. Ensure user is group member
3. Check role path format
4. Test API key with curl:
```bash
curl -H "x-api-key: YOUR_KEY" \
  https://apis.roblox.com/cloud/v2/groups/GROUP_ID/memberships
```

### "Page not found" / 404 errors

**Causes:**
- Incorrect web server configuration
- Missing .htaccess
- mod_rewrite not enabled

**Fix:**
1. Verify DocumentRoot points to public_html
2. Check .htaccess is present
3. Enable mod_rewrite (Apache)
4. Test with: `https://your-domain.com/index.php?action=listApps`

### File permission errors

**Causes:**
- Data directory not writable
- Wrong ownership

**Fix:**
```bash
# Set ownership (replace www-data with your web server user)
chown -R www-data:www-data data/

# Set permissions
chmod -R 755 data/
```

## 🔒 Security Checklist

- [ ] `.env` file has restricted permissions (600)
- [ ] `.env` is in `.gitignore`
- [ ] HTTPS is enabled
- [ ] API keys are not committed to git
- [ ] Data directory is outside web root (if possible)
- [ ] PHP display_errors is off in production
- [ ] Regular backups of `data/` directory
- [ ] API keys are rotated periodically

## 📊 Monitoring

### Check Submissions

View submissions:
```
https://your-domain.com/index.php?action=listSubmissions
```

### Check Application Stats

```php
// Count submissions
$files = glob(__DIR__ . '/data/submissions/*.json');
echo "Total submissions: " . count($files);

// Count passed
$passed = 0;
foreach ($files as $file) {
    $data = json_decode(file_get_contents($file), true);
    if ($data['passed']) $passed++;
}
echo "Passed: $passed";
```

## 🚀 Going Live

1. **Test thoroughly** in Studio first
2. **Set APP_DEBUG=false** in .env
3. **Monitor submissions** for first few days
4. **Adjust pass scores** based on results
5. **Fine-tune AI grading criteria** as needed
6. **Set up backups** for data directory
7. **Monitor API usage** and costs

## 📞 Support

If you encounter issues:

1. Check this guide thoroughly
2. Review error logs (PHP and web server)
3. Test each component individually
4. Verify all API keys are correct
5. Check Roblox DevForum for related issues

## 🎯 Best Practices

1. **Start simple**: Begin with 3-4 questions
2. **Limit short answers**: Max 3 per application (costs money)
3. **Clear criteria**: Be specific in grading criteria
4. **Reasonable pass scores**: 70-80% is recommended
5. **Test in Studio**: Always test before publishing
6. **Monitor costs**: Track AI API usage
7. **Backup regularly**: Backup `data/` directory
8. **Rotate keys**: Change API keys periodically

---

✅ Setup complete! Your Application Center is ready to use.