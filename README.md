# 🚀 Application Center - Roblox Group Application System

A full-stack, ultra-modern application center builder for Roblox groups featuring AI-powered grading, custom DSL format, and beautiful UI.

## ✨ Features

- **🎨 Ultra-Modern UI**: Glassmorphism design with dark/light mode support
- **🤖 AI-Powered Grading**: Automatic grading using Gemma-3-27B-IT via Featherless AI
- **📝 Custom DSL**: `.astappcnt` format for application definitions
- **🎮 Roblox Integration**: Luau client script for in-game application forms
- **🔄 Auto-Promotion**: Automatic group role promotion on passing applications
- **💾 JSON Storage**: No database required - uses JSON file storage
- **🎯 Drag-and-Drop Builder**: Intuitive application builder interface
- **📊 Multiple Question Types**: Multiple choice, short answer, and checkboxes
- **🔒 Secure**: Environment-based configuration with .env support

## 🏗️ Architecture

```
/public_html/          # Web root
  ├── index.php        # Main router (index.php?action=XYZ)
  ├── builder.html     # Application builder UI
  └── assets/
      ├── css/
      │   └── style.css       # Ultra-modern styles
      └── js/
          └── builder.js      # Drag-and-drop builder

/data/                 # JSON storage
  ├── apps/            # Application configs (.astappcnt files)
  ├── submissions/     # User submissions
  └── creators/        # Creator metadata

/src/                  # PHP backend
  ├── Env.php                 # Environment loader
  ├── Helpers.php             # Utility functions
  ├── AstParser.php           # .astappcnt parser
  ├── AstSerializer.php       # .astappcnt serializer
  ├── AppController.php       # Application CRUD
  ├── SubmissionController.php # Submission handling
  ├── FeatherlessGrader.php   # AI grading service
  └── PromotionService.php    # Roblox promotion

/roblox/
  └── AppCenterClient.lua     # Roblox Luau client
```

## 🚀 Quick Start

### 1. Setup Environment

Copy `.env.example` to `.env` and configure:

```bash
cp .env.example .env
```

Edit `.env`:
```env
ROBLOX_API_KEY=your_roblox_api_key
FEATHERLESS_API_KEY=rc_your_featherless_key
FEATHERLESS_MODEL=google/gemma-3-27b-it
FEATHERLESS_BASE_URL=https://api.featherless.ai/v1
```

### 2. Get API Keys

**Roblox API Key:**
1. Visit [Roblox Creator Hub](https://create.roblox.com/credentials)
2. Create a new API key with group management permissions
3. Add to `.env`

**Featherless AI API Key:**
1. Visit [Featherless.ai](https://featherless.ai)
2. Sign up and get your API key
3. Add to `.env`

### 3. Deploy

Upload to your web server:
```bash
# Ensure proper permissions
chmod 755 public_html
chmod 755 data
chmod 644 .env
```

Access the builder at: `https://your-domain.com/`

## 📖 Usage Guide

### Creating an Application

1. **Open Builder**: Navigate to your domain
2. **Create New App**: Click "New Application"
3. **Configure Settings**:
   - Application name
   - Description
   - Roblox Group ID
   - Target role (e.g., `groups/123456/roles/99999999`)
   - Pass score percentage
4. **Style**: Customize colors
5. **Add Questions**: Click "Add Question" and choose type:
   - **Multiple Choice**: Single correct answer
   - **Short Answer**: AI-graded text response (max 300 chars)
   - **Checkboxes**: Multiple correct answers
6. **Save**: Click "Save" to generate `.astappcnt` file

### Roblox Integration

1. **Insert Script**: Add `AppCenterClient.lua` as a ModuleScript in ServerScriptService
2. **Create Trigger**: Use a ProximityPrompt, ClickDetector, or GUI button
3. **Initialize**:

```lua
local AppCenter = require(game.ServerScriptService.AppCenterClient)

local app = AppCenter.new({
    AppId = "your_app_id_here",
    ServerUrl = "https://your-domain.com"
})

-- Show to player
app:ShowToPlayer(player)
```

## 📋 .astappcnt Format

The `.astappcnt` format is a custom DSL for defining applications:

```
APP {
  id: "app_id";
  name: "Application Name";
  description: "Description";
  group_id: 123456;
  target_role: "groups/123456/roles/99999999";
  pass_score: 75;
}

STYLE {
  primary_color: "#ff4b6e";
  secondary_color: "#1f2933";
  background: "gradient:linear,#1f2933,#111827";
  font: "Inter";
  button_shape: "pill";
}

QUESTION "q1" TYPE "multiple_choice" {
  text: "Question text?";
  points: 10;
  options: [
    {id:"a", text:"Option A", correct:true},
    {id:"b", text:"Option B", correct:false}
  ];
}

QUESTION "q2" TYPE "short_answer" {
  text: "Question text?";
  max_length: 300;
  points: 20;
  grading_criteria: "Criteria for AI grading";
}

QUESTION "q3" TYPE "checkboxes" {
  text: "Question text?";
  points: 20;
  max_score: 20;
  scoring: {
    points_per_correct: 5;
    penalty_per_incorrect: 1;
  };
  options: [
    {id:"a", text:"Option A", correct:true},
    {id:"b", text:"Option B", correct:false}
  ];
}
```

## 🔌 API Reference

All endpoints use `index.php?action=ACTION_NAME`

### Application Management

**Create/Save Application**
```
POST index.php?action=saveApp
Content-Type: application/json

{
  "app": { ... },
  "style": { ... },
  "questions": [ ... ]
}
```

**Load Application**
```
GET index.php?action=loadApp&id=APP_ID
```

**List Applications**
```
GET index.php?action=listApps
```

**Get Config (for Roblox)**
```
GET index.php?action=getConfig&id=APP_ID
```

### Submissions

**Submit Application**
```
POST index.php?action=submit
Content-Type: application/json

{
  "app_id": "APP_ID",
  "user_id": 123456,
  "answers": {
    "q1": "answer_id",
    "q2": "short answer text",
    "q3": ["option_a", "option_b"]
  }
}
```

**Get Submission**
```
GET index.php?action=getSubmission&id=SUBMISSION_ID
```

**List Submissions**
```
GET index.php?action=listSubmissions&app_id=APP_ID
```

## 🎨 Customization

### Themes

Toggle between dark/light mode using the theme toggle in the header. Theme preference is saved in localStorage.

### Colors

Customize application colors in the Style section of the builder. Colors are applied to the Roblox UI automatically.

## 🔒 Security

- API keys stored in `.env` (never commit to git)
- Input sanitization on all user data
- CORS headers for Roblox integration
- Secure file storage outside web root
- XSS protection with HTML escaping

## 📊 Grading System

### Multiple Choice
- Correct answer: Full points
- Incorrect answer: 0 points

### Checkboxes
- Points per correct selection
- Penalty per incorrect selection
- Score capped at max_score

### Short Answer
- AI-graded using Gemma-3-27B-IT
- Max 3 short answer questions per application
- Max 300 characters per answer
- Grading based on criteria provided

## 🤝 Contributing

This is a production-ready system. For modifications:

1. Follow existing code structure
2. Maintain security practices
3. Test thoroughly before deployment
4. Update documentation

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details

## 🆘 Support

For issues or questions:
1. Check the documentation
2. Review example `.astappcnt` file
3. Verify API keys are configured correctly
4. Check browser console for errors

## 🔧 Troubleshooting

**Application won't save:**
- Check `.env` configuration
- Verify directory permissions
- Check PHP error logs

**Roblox can't connect:**
- Enable HTTP requests in game settings
- Verify ServerUrl is correct
- Check CORS headers

**AI grading fails:**
- Verify Featherless API key
- Check API quota limits
- Review grading criteria format

**Promotion fails:**
- Verify Roblox API key has group permissions
- Check group ID and role path format
- Ensure user is in the group

## 🎯 Best Practices

1. **Limit short answer questions** to 3 per application (AI cost)
2. **Use clear grading criteria** for short answers
3. **Set realistic pass scores** (70-80% recommended)
4. **Test applications** before deploying to production
5. **Monitor submissions** regularly
6. **Keep API keys secure** and rotate periodically

## 🚀 Advanced Features

### Custom Styling
Modify `public_html/assets/css/style.css` for custom branding

### Extended Question Types
Add new question types by extending:
- `AstParser.php` - Parse new formats
- `AstSerializer.php` - Serialize new formats
- `SubmissionController.php` - Add grading logic
- `AppCenterClient.lua` - Add UI components

### Webhooks
Integrate Discord/Slack notifications by modifying `SubmissionController.php`

---

Built with ❤️ for Roblox Groups • Powered by Gemma-3-27B-IT