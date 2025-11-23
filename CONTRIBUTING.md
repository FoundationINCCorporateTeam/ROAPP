# Contributing to Application Center

Thank you for your interest in contributing to the Application Center project!

## 🧪 Testing

Before submitting any changes, run the test suite:

```bash
php tests/run_tests.php
```

All tests must pass before merging.

## 📝 Code Style

### PHP
- Follow PSP-12 coding standards
- Use meaningful variable and function names
- Add PHPDoc comments for all public methods
- Keep functions focused and single-purpose
- Use type hints where possible (PHP 8+)

### JavaScript
- Use ES6+ features
- Use camelCase for variables and functions
- Use PascalCase for classes
- Add JSDoc comments for public methods
- Keep functions pure when possible

### CSS
- Use CSS custom properties (variables)
- Follow BEM naming convention where appropriate
- Group related properties
- Add comments for complex sections

## 🏗️ Project Structure

```
/public_html/          # Web-accessible files only
/src/                  # PHP backend classes
/data/                 # JSON storage (gitignored)
/roblox/              # Lua/Luau scripts
/tests/               # Test files
```

## 🔒 Security Guidelines

1. **Never commit API keys** - Use .env files
2. **Sanitize all user input** - Use `sanitize()` helper
3. **Validate data** - Use `validateRequired()` and custom validation
4. **Escape output** - Prevent XSS attacks
5. **Use prepared statements** - If adding database support
6. **Check file permissions** - Ensure sensitive files are protected

## 🐛 Bug Reports

When reporting bugs, include:
- PHP version
- Error messages (from logs)
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable

## ✨ Feature Requests

For new features:
- Describe the use case
- Explain why it's needed
- Provide examples of how it would work
- Consider backwards compatibility

## 🔄 Pull Request Process

1. Fork the repository
2. Create a feature branch (`feature/amazing-feature`)
3. Make your changes
4. Run tests: `php tests/run_tests.php`
5. Check syntax: `php -l your_file.php`
6. Commit with clear messages
7. Push to your fork
8. Open a Pull Request

### Commit Message Format

```
type: subject

body (optional)
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance tasks

Example:
```
feat: Add support for file upload questions

- Add new question type 'file_upload'
- Update parser to handle file references
- Add file size validation
```

## 📚 Adding New Question Types

To add a new question type:

1. **Update AstParser.php**: Add parsing logic
2. **Update AstSerializer.php**: Add serialization logic
3. **Update SubmissionController.php**: Add grading logic
4. **Update builder.js**: Add UI for creating/editing
5. **Update AppCenterClient.lua**: Add Roblox UI component
6. **Add tests**: Test parsing and grading
7. **Update documentation**: Document the new type

Example structure:
```
QUESTION "q1" TYPE "new_type" {
  text: "Question text";
  points: 10;
  // Type-specific properties
}
```

## 🧩 Adding New Features

### Backend Features

1. Create new PHP class in `/src/`
2. Follow existing class structure
3. Add error handling
4. Add validation
5. Update index.php router if needed
6. Add tests

### Frontend Features

1. Update builder.js or create new JS file
2. Add CSS in style.css
3. Follow existing patterns
4. Ensure responsive design
5. Test in multiple browsers

### Roblox Features

1. Update AppCenterClient.lua
2. Test in Roblox Studio
3. Ensure compatibility with Luau
4. Handle errors gracefully
5. Document usage

## 🎨 Styling Guidelines

- Maintain glassmorphism design language
- Support dark/light themes
- Use CSS custom properties
- Ensure smooth animations
- Follow existing color scheme
- Maintain accessibility

## 📖 Documentation

When adding features:
- Update README.md
- Update SETUP.md if needed
- Add inline code comments
- Update API reference
- Add usage examples

## ⚡ Performance

- Minimize API calls (especially to Featherless AI)
- Optimize file I/O operations
- Use caching where appropriate
- Test with large datasets
- Profile before and after changes

## 🧰 Development Tools

Recommended tools:
- **PHP**: PHP 8.3+, Composer (optional)
- **JavaScript**: Node.js, ESLint
- **Testing**: PHPUnit (optional)
- **IDE**: VS Code with PHP and Lua extensions
- **Roblox**: Roblox Studio

## 📋 Checklist for Contributors

Before submitting:
- [ ] Code follows style guidelines
- [ ] Tests added/updated
- [ ] All tests pass
- [ ] Documentation updated
- [ ] No security vulnerabilities introduced
- [ ] No API keys or secrets in code
- [ ] Backwards compatible (or migration path provided)
- [ ] Code is commented
- [ ] Commit messages are clear

## 🙏 Thank You!

Every contribution helps make Application Center better for the Roblox community!

## 📞 Questions?

- Check existing documentation
- Search closed issues
- Open a new issue for clarification

---

Happy coding! 🚀
