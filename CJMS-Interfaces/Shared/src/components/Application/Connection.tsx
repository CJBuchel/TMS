// 
// Connection to the server (monitor modal)
// 
import { comm_service } from "@cjms_shared/services";
import React, { Component, useEffect, useState }  from "react";
import "../../assets/stylesheets/ConnectionModal.scss";

interface IProps {
  app:any;
}

interface IState {
  isOnline:boolean;
  retryCount:number;
  loop?:any;
}

export class ConnectionCheck extends Component<IProps, IState> {
  private count = 0;
  constructor(props:any) {
    super(props);

    this.state = {
      isOnline:true,
      retryCount:0
    }

    comm_service.listeners.onSystemRefresh(() => {
      window.location.reload();
    });

    this.connectionCheck = this.connectionCheck.bind(this);
  }

  async componentDidMount() {
    this.startLoop();
  }
  
  componentWillUnmount() {
    clearInterval(this.state.loop);
  }

  connectionCheck() {
    fetch("http://"+window.location.host).then(res => {
      this.setState({isOnline:true});
      this.count = 0;
      this.setState({retryCount:0});
    }).catch((error) => {
      this.setState({isOnline:false});
      this.count++;
      this.setState({retryCount: this.count});
    });
  }

  startLoop() {
    this.connectionCheck();
    this.setState({loop: setInterval(this.connectionCheck, 2000)});
  }

  render() {
    if (this.state.isOnline) {
      return (this.props.app);
    } else {

      return (
        <div className="ConnectionWrapper">
          <div className="ConnectionModalApp">{this.props.app}</div>
          <div className="ConnectionModalBackdrop"></div>
          <div className="ConnectionModal animated fadeIn">
            <h1>NO CONNECTION</h1>
            <h4>Server Fault: Cannot Ping CJMS</h4>
            <h5>Retry Count: {this.state.retryCount === 69 ? `${this.state.retryCount} Nice` : this.state.retryCount}</h5>
          </div>
        </div>
      )
    }
  }
}