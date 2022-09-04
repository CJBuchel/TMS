import React, { Component } from "react";
import InfiniteTable from "../Containers/InfiniteTable";

import "../../assets/application.scss";

interface IProps {}

interface IState {}

export default class Display extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);
  }

  render() {
    return (
      // <div id='audience-display-app' className='audience-display-app'>
      // </div>
      <InfiniteTable/>
    );
  }
}