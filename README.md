![Webnestify Logo](https://webnestify.cloud/wp-content/uploads/2023/11/webnestify-logo-dark-300x109.png)

![Webnestify Logo](https://webnestify.cloud/wp-content/uploads/2025/01/omni-manage-logo-2.jpg)

# Webnestify OmniManage

**Webnestify OmniManage** is a comprehensive suite of automation scripts designed to simplify and streamline the management of WordPress sites, Cloudflare settings, and server environments. Whether you're a developer, system administrator, or site owner, this repository provides the tools you need to automate essential maintenance tasks and improve operational efficiency.

---

## 🚀 Features

### WordPress Management
- **Update Plugins and Themes**: Automatically check and update WordPress plugins and themes for multiple installations.
- **Adjust Memory Limits**: Easily configure the WordPress memory limit across all installations to ensure optimal performance.
- **Integrity Checks**: Verify WordPress core file integrity using checksums to detect and resolve potential issues.

### Cloudflare Integration
- **Bot Protection**: Enable bot protection for all associated zones using your Cloudflare API token.
- **Cache Management**: Flush caches and create tailored page rules (e.g., caching for `/wp-content/uploads`).
- **Zone Management**: Export zone data to a CSV for detailed records and audit purposes.

### System Maintenance
- **System Updates**: Automatically update packages, clean up unused files, and apply distribution upgrades.
- **Process Monitoring**:
  - Check running processes for all system users.
  - Monitor processes with open ports for potential risks.
- **Cron Jobs**: Inspect and manage all users' scheduled cron jobs.

---

### 🌐 Supported Management Panels

Currently, **Webnestify OmniManage** supports:
- **Enhance**
- **RunCloud**

We’re constantly working to add support for more panels in future updates.

---

### 🎉 New Features Coming Constantly
We’re always working to improve Webnestify OmniManage! Expect frequent updates and additions to make managing your WordPress, Cloudflare, and server environments even easier.

---

## ⚠️ Disclaimer

> ### **⚠️ Important Notice**
>
> **Webnestify OmniManage is provided as-is, without warranty of any kind.**
>
> - Webnestify **is not responsible** for any damages, data loss, or system issues caused by the use of this software.
> - Ensure you have up-to-date backups before using any of the provided scripts.
> - Use at your own risk and test in a controlled environment before deploying to production.

---

## 🔑 Cloudflare API Configuration

To use the Cloudflare integration features, you need to create a Cloudflare API token with the following permissions:

| **Permission**          | **Access Level** | **Purpose**                                   |
|--------------------------|------------------|-----------------------------------------------|
| **Config Rules**         | Edit             | Manage configuration rules for zones.         |
| **Bot Management**       | Edit             | Enable or configure bot protection.           |
| **Zone WAF**             | Edit             | Edit Web Application Firewall (WAF) settings. |
| **Zone**                 | Read             | Access information about your zones.          |
| **Cache Purge**          | Purge            | Flush cache for the specified zones.          |
| **Page Rules**           | Edit             | Create or modify page rules.                  |
| **Firewall Services**    | Edit             | Manage firewall settings.                     |

### Steps to Create the API Token

1. Log in to your Cloudflare account.
2. Navigate to **My Profile > API Tokens**.
3. Click **Create Token**.
4. Under **Custom Token**, configure the above permissions.
5. Specify the corresponding zone(s) you want to manage (or allow access to all zones if applicable).
6. Save the token and use it in Webnestify OmniManage.

---

## 💡 How to Use

To execute the script, set it executable:
```bash
chmod +x wn-omnimanage.sh && ./wn-omnimanage.sh
```
And follow menu options.

---

## 💡 Why Choose Webnestify OmniManage?

- **Automation First**: Save time and reduce manual effort with fully automated scripts.
- **Scalability**: Manage multiple WordPress installations and server environments with ease.
- **Customizable**: Tailor scripts to fit your unique setup or hosting platform.
- **Security-Focused**: Improve site and server security with integrations like Cloudflare.

---

## 📌 Notes

- **Requirements**:
  - [WP-CLI](https://wp-cli.org/) for WordPress management.
  - `jq` for processing JSON data in Cloudflare integrations.
  - Appropriate user permissions for executing system-level scripts.

---

## 🌟 Roadmap

This repository is constantly evolving! Here’s what’s planned:
- **Enhanced Monitoring**: Advanced reporting for server health and performance metrics.
- **Support for Additional Platforms**: Extend compatibility to other hosting platforms like xCloud and others.
- **Advanced Security Features**: Integrations with more security tools and firewalls.
- **Customizable Dashboards**: Provide an interface for visualizing site and server metrics.

Stay tuned for frequent updates and new features! Contributions and suggestions are always welcome.

---

## 🤝 Contributions

We welcome contributions to make **Webnestify OmniManage** even better! Feel free to fork the repository, make your changes, and submit a pull request.

---

## 📝 License

This project is licensed under the [MIT License](LICENSE).

---

## 🌐 Connect with Us

Have questions or need help? Join our community:
- Discord: [Webnestify Community](https://discord.gg/JNqn5rHf)
- Email: [support@webnestify.com](mailto:support@webnestify.com)

---
