import React, {Component} from "react";

import "../../assets/Setup.scss"

interface IProps {}
interface IState {}

export default class Setup extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);
    this.state = {}
  }

  render() {
    return(
      <div className="setup-main">
        <div className="container">
          <h3>Schedule</h3>
          <a href="">Upload CSV</a><br/>
          <a href="https://firstaustralia.org/fll-scheduler/">Generate Schedule/CSV</a><br/>


          <h3>Event Name</h3>
          <input/>
        </div>
      </div>
    );
  }
}