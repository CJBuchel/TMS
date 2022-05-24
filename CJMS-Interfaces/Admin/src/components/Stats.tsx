import React, {Component} from "react";

interface IProps {}

interface IState {}

export default class Stats extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {}
  }

  render() {
    return(
      <h1>Stats Page</h1>
    );
  }
}