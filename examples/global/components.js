var componentSettings = {
  "conditions": {
    "authenticated": function ()  {
      return window.isAuthenticated;
    },
    "not-authenticated": function () {
      return !window.isAuthenticated;
    }
  },
  "components": [
    {
      "componentId": 'app-navigation',
      "src": "app.components.NavigationComponent",
      "conditions": "authenticated"
    },
    {
      "componentId": 'app-login',
      "src": "app.components.LoginComponent",
      "conditions": "not-authenticated"
    },
    {
      "componentId": 'app-marquee',
      "src": "app.components.MarqueeComponent"
    },
    {
      "componentId": 'app-profile-overview',
      "src": "app.components.ProfileOverViewComponent"
    },
    {
      "componentId": 'app-social-media',
      "src": "app.components.SocialMediaComponent"
    },
    {
      "componentId": 'app-list',
      "src": "app.components.ListComponent"
    }
  ],

  "hidden": [],

  "targets": {
    "header": [
      {
        "id": "navigation",
        "componentId": "app-navigation",
        "urlPattern": "global",
        "conditions": "authenticated"
      }
    ],

    "main": [
      {
        "id": "app-login",
        "componentId": "app-login",
        "urlPattern": ["", "landing", "logout"]
      },
      {
        "id": "app-list",
        "componentId": "app-list",
        "urlPattern": ["home", "event/*path"]
      }
    ],
   "below-header": [
      {
        "id": "app-marquee",
        "componentId": "app-marquee",
        "urlPattern": ["home", "event/*path"]
      }
   ],
   "sidebar-top": [
      {
        "id": "app-profile-overview",
        "componentId": "app-profile-overview",
        "urlPattern": ["home", "event/*path"]
      }
   ],
   "sidebar-bottom": [
      {
        "id": "app-social-media",
        "componentId": "app-social-media",
        "urlPattern": ["home", "event/*path"]
      }
   ],
   "right-column": [
      {
        "id": "app-list-two",
        "componentId": "app-list",
        "urlPattern": "event/:id",
        "reInstantiateOnUrlParamChange": true
      }
   ]
  }
}
