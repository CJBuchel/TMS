import React, {ChangeEvent, Component} from "react";

import "../../assets/Setup.scss"
import Offline from "./Offline";
import OnlineLink from "./OnlineLink";

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
        <div className="setup-row">
          <Offline/>
          <OnlineLink/>
        </div>
      </div>
    );
  }
}