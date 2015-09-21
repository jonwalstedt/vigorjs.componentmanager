var componentSettings = {
  conditions: {
    authenticated: function ()  {
      return (window.localStorage.getItem("isAuthenticated") === "true");
    },
    "not-authenticated": function () {
      return !(window.localStorage.getItem("isAuthenticated") === "true");
    }
  },
  components: [
    {
      id: "app-navigation",
      src: "app.components.NavigationComponent",
      conditions: "authenticated"
    },
    {
      id: "app-login",
      src: "app.components.LoginComponent",
      conditions: "not-authenticated"
    },
    {
      id: "app-marquee",
      src: "app.components.MarqueeComponent"
    },
    {
      id: "app-profile-overview",
      src: "app.components.ProfileOverViewComponent"
    },
    {
      id: "app-social-media",
      src: "app.components.SocialMediaComponent"
    },
    {
      id: "app-list",
      src: "app.components.ListComponent"
    },
    {
      id: "app-banner",
      src: "http://www.bido.com/Banner?s=20060&a=0000"
    },

  ],


  targets: {
    header: [
      {
        id: "navigation",
        componentId: "app-navigation",
        urlPattern: "global"
      }
    ],

    main: [
      {
        id: "app-login",
        componentId: "app-login",
        urlPattern: ["", "landing", "logout"]
      },
      {
        id: "app-list",
        componentId: "app-list",
        urlPattern: ["home", "event/*path"]
      }
    ],

   "below-header": [
      {
        id: "app-marquee",
        componentId: "app-marquee",
        urlPattern: ["home", "event/*path"]
      }
   ],

   "sidebar-top": [
      {
        id: "app-profile-overview",
        componentId: "app-profile-overview",
        urlPattern: ["home", "event/*path"]
      }
   ],

   "sidebar-bottom": [
      {
        id: "app-social-media",
        componentId: "app-social-media",
        urlPattern: ["home", "event/*path"]
      },
      {
        id: "app-banner",
        componentId: "app-banner",
        urlPattern: ["home", "event/*path"],
        args: {
          iframeAttributes: {
            scrolling: "no",
            border: 0,
            frameborder: 0,
            width: 200,
            height: 60,
            style: "margin: 20px auto; display: block;"
          }
        }
      }
   ],

   "right-column": [
      {
        id: "app-list-two",
        componentId: "app-list",
        urlPattern: "event/:id",
        reInstantiateOnUrlParamChange: true
      }
   ]
  }
}
