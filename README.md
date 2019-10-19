# handle_ping
Cron script for pinging websites to check handle availability (e.g. check if @username is available on Twitter).

Twitter, Instagram support right out of the box.

## Simple Installation
### Requirements
- Gmail email address
- [Heroku](https://heroku.com) account

### Steps
- Create Heroku project and push repo

   ```
   heroku create
   git push heroku master
   ```
- In your Heroku project's config settings, add these ENV variables

  - `EMAIL_USERNAME` (your gmail email address)
  - `EMAIL_PASSWORD` (your gmail password)
  - The handles you want with format `SERVICE_HANDLE` (e.g. `TWITTER_HANDLE`, `INSTAGRAM_HANDLE`)
  
- Add [Heroku Scheduler](https://elements.heroku.com/addons/scheduler) add-on
- In the Scheduler's settings, add a new cron job: `ruby ping.rb`
- That's it!

### Add additional services
Currently Twitter and Instagram are only supported, but if you'd like to add additional services, amend the constant `HANDLE_URI_PATTERNS` in `ping.rb` to include the new service(s). For example, if you want to add LinkedIn, you'd change `HANDLE_URI_PATTERNS` to equal:

```
{
  'TWITTER'   => "http://www.twitter.com/:username",
  'INSTAGRAM' => "http://www.instagram.com/:username",
  'LINKEDIN'  => "http://www.linkedin.com/in/:username"
}
```

and then add `LINKEDIN_HANDLE` to your ENV variables.
