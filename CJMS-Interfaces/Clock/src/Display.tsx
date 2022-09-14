import { Component, ReactNode } from "react";
import "./assets/application.scss";

import "./assets/Display.scss";

interface IProps {}

interface IState {}

export default class Display extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {}
  }

  render() {
    return(
      <div className="Display-Timer">

        <div className="Display-Timer-Top">
          <h1>Match Status</h1>
        </div>

        <div className="Display-Timer-Middle">
          <h1>Test</h1>
        </div>

        <div className="Display-Timer-Bottom">
          
          <div className="column-left-team">
            <h1>On Table: </h1>
          </div>

          <div className="column-match-number">
            <h1>Match</h1>
            <div className="content">
              <h1>#10</h1>
            </div>
          </div>

          <div className="column-right-team">
            <h1>On Table: </h1>
          </div>
        </div>
      </div>
    );
  }
}