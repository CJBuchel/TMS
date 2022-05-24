import React, {Component} from "react";

interface IProps {}

interface IState {}

export default class Setup extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {}
  }

  render() {
    return(<h1>Big ol Test</h1>);
  }
}