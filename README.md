<section class="hero-unit">
  <div class="hero-unit__content">
    <h1 class="hero-unit__title">VigorJS <br/>Component <br/>Manager</h1>
    <p class="hero-unit__desc">The VigorJS ComponentManager is a small framework intended to help decouple and simplify the application structure of large scale [Backbone](http://backbonejs.org/) applications.</p>

    <div class="hero-unit__links">
      <a href="http://jonwalstedt.github.io/vigorjs.componentmanager/js/vigorjs.componentmanager.min.js" class="hero-unit__link">Download (0.0.5)</a>
      <a href="http://jonwalstedt.github.io/vigorjs.componentmanager/docs/" class="hero-unit__link">Documentation</a>
      <a href="http://jonwalstedt.github.io/vigorjs.componentmanager/examples/" class="hero-unit__link">Examples</a>
    </div>
  </div>
</section>

<section class="about">
  <div class="about__wrapper">
    <ul>
      <li>
        <h2>What does it do?</h2>
        <p>After initializing the ComponentManager with your [settings](http://jonwalstedt.github.io/vigorjs.componentmanager/docs/#settings) it will load, instantiate and add all your components to the DOM simply by calling the [refresh](http://jonwalstedt.github.io/vigorjs.componentmanager/docs/#refresh) method with a [filter](http://jonwalstedt.github.io/vigorjs.componentmanager/docs/#filter). Any components that doesn't match the passed filter will be disposed (depending on which [options](http://jonwalstedt.github.io/vigorjs.componentmanager/docs/#options) you use).</p>
      </li>
      <li>
        <h2>Why?</h2>
        <p>As a application grows in in size it's easy to let different parts of the application get tangled up into each other. Components that are tightly coupled with the application framework or other components are harder to reuse or extend. The ComponentManager tries to solve this by separating your components from the application logic itself.</p>
      </li>
      <li>
        <h2>Getting started</h2>
        <p>To get started head over to the [getting started](http://jonwalstedt.github.io/vigorjs.componentmanager/docs/#getting-started) section or look through the [examples](http://jonwalstedt.github.io/vigorjs.componentmanager/examples) and their setup.</p>
      </li>
    </ul>
  </div>
</section>