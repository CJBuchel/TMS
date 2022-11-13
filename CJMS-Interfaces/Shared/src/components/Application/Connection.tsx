// 
// Connection to the server (monitor modal)
// 
import { comm_service } from "@cjms_shared/services";
import React, { Component, useEffect, useState }  from "react";
import "../../assets/stylesheets/ConnectionModal.scss";

// var count = 0;
// export const ConnectionCheck = (props:any) => {
//   const [isOnline, setOnline] = useState(true);
//   const [retryCount, setRetryCount] = useState(0);
//   useEffect(() => {
//     setInterval(() => {
//       fetch("http://"+window.location.host)
//       .then(res => {
//         setOnline(true);
//         count = 0;
//         setRetryCount(0);
//       }).catch((error) => {
//         count++;
//         setRetryCount(count);
//         setOnline(false);
//       });
//     }, 2000);
//   }, []);

//   function AppRender() {

//     // If there is a connection to server render normally
//     if (isOnline) {
//       return (
//         props.children
//       )
//     } else {
//       var retryString = retryCount.toString();
//       if (retryCount === 69) {
//         retryString = retryString + " Nice";
//       }

//       return (
//         <div className="ConnectionWrapper">
//           <div className="ConnectionModalApp">{props.children}</div>
//           <div className="ConnectionModalBackdrop"></div>
//           <div className="ConnectionModal animated fadeIn">
//             <h1>NO CONNECTION</h1>
//             <h4>Server Fault: Cannot Ping CJMS</h4>
//             <h5>Retry Count: {retryString}</h5>
//           </div>
//         </div>
//       )
//     }
//   }

//   return (
//     AppRender()
//   )
// }

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
      isOnline:false,
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