import { Requests } from "@cjms_interfaces/shared";
import { request_namespaces } from "@cjms_shared/services";
import { Component } from "react";

import "../../../assets/Setup.scss"

interface IProps {}

interface IState {
  admin:string;
  scorekeeper:string;
  referee:string;
  head_referee:string;
}

export default class UsersSetup extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      admin:"",
      scorekeeper:"",
      referee:"",
      head_referee:"",
    }

    this.handleSubmit = this.handleSubmit.bind(this);
  }

  onAdminChange(e:string) {
    this.setState({admin: e});
  }

  onScoreKeeperChange(e:string) {
    this.setState({scorekeeper: e});
  }

  onRefereeChange(e:string) {
    this.setState({referee: e});
  }

  onHeadRefereeChange(e:string) {
    this.setState({head_referee: e});
  }

  handleSubmit() {
    console.log("Submitted");
    this.state.admin.length > 0 ? Requests.CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_user_update, {user: "admin", password: this.state.admin}) : '';
    this.state.scorekeeper.length > 0 ? Requests.CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_user_update, {user: "scorekeeper", password: this.state.scorekeeper}, true) : '';
    this.state.referee.length > 0 ? Requests.CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_user_update, {user: "referee", password: this.state.referee}, true) : '';
    this.state.head_referee.length > 0 ? Requests.CJMS_FETCH_GENERIC_POST(request_namespaces.request_post_user_update, {user: "head_referee", password: this.state.head_referee}, true) : '';
  }

  render() {
    return(
      <div className="setup-main">
        <div className="container">

          {/* Users form */}
          <form onSubmit={(e) => {e.preventDefault()}}>
            <h3>Admin</h3>
            <input type="password" placeholder="Admin Password..." onChange={e => this.onAdminChange(e.target.value)}/>
            <h3>Score Keeper</h3>
            <input type="password" placeholder="Score Keeper Password..." onChange={e => this.onScoreKeeperChange(e.target.value)}/>
            <h3>Referee</h3>
            <input type="password" placeholder="Referee Password..." onChange={e => this.onRefereeChange(e.target.value)}/>
            <h3>Head Referee</h3>
            <input type="password" placeholder="Head Referee Password..." onChange={e => this.onHeadRefereeChange(e.target.value)}/>

            <button className="hoverButton back-red" onClick={() => {window.location.reload()}}>Clear</button>
            <button className="hoverButton back-green" onClick={this.handleSubmit}>Submit</button>
          </form>
        </div>

      </div>
    );
  }
}