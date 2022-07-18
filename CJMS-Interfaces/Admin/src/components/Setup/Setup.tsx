import React, {Component} from "react";
import "../../assets/Setup.scss";

interface IProps {}

interface IState {}

export default class Setup extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {}
  }

  render() {
    return(
      <div className="row">
        <div className="setup-main">
          <h1>Setup</h1>
        </div>

        <div className="data-preview">
          <h1>Data Preview</h1>
        </div>
      </div>
    );
  }
}