import React from "react";

import CreateTask from "components/Tasks/Create";
import { Route, Switch, BrowserRouter as Router } from "react-router-dom";

import Dashboard from "./components/Dashboard";

const App = () => (
  <Router>
    <Switch>
      <Route exact component={Dashboard} path="/" />
      <Route exact component={CreateTask} path="/tasks/create" />
      <Route exact path="/about" render={() => <div>About</div>} />
      <Route exact component={Dashboard} path="/dashboard" />
    </Switch>
  </Router>
);

export default App;
