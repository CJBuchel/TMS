import { CJMS_FETCH_GENERIC_GET } from "@cjms_interfaces/shared/lib/components/Requests/Request";
import { comm_service, request_namespaces } from "@cjms_shared/services";
import React, { Component } from "react";
import { Navigate, useNavigate } from "react-router-dom";
import Select, { SingleValue } from "react-select";

import "../../assets/loader.scss";
import "../../assets/Setup.scss";

interface SelectOption {
  value: any,
  label: String
}

interface IProps {
  setScorer:Function;
  setTable:Function;
}

interface IState {
  tableOptions:SelectOption[];
  eventData:any;

  table:string;
  scorer:string;

  setupComplete:boolean;
}

export default class Setup extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      tableOptions: [],
      eventData: [],
      table: '',
      scorer: '',
      setupComplete: false,
    }
  }

  setTableOptions(data:any) {
    const tables:SelectOption[] = [];
    this.setState({eventData: data.data});
    if (data?.data) {
      for (const table of data?.data?.event_tables) {
        tables.push({value: table, label: table});
      }
    }

    this.setState({tableOptions: tables});
  }

  async componentDidMount() {
    // sessionStorage.clear();
    const data:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_event, true);
    this.setTableOptions(data);
    
    comm_service.listeners.onEventUpdate(async () => {
      const data:any = await CJMS_FETCH_GENERIC_GET(request_namespaces.request_fetch_event, true);
      this.setTableOptions(data);
    });
  }

  async handleSubmit(e:React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    this.props.setScorer({scorer: this.state.scorer});
    this.props.setTable({table: this.state.table});
    console.log(this.state.scorer);
    console.log(this.state.table);
    
    this.setState({setupComplete: true});
  }

  onTableChange(e:SingleValue<SelectOption>) {
    this.setState({table: e?.value});
  }

  onScorerChange(e:React.ChangeEvent<HTMLInputElement>) {
    this.setState({scorer: e.target.value});
  }

  render() {
    if (this.state.eventData) {
      return(
        <div className="Setup">
          <form onSubmit={(e:React.FormEvent<HTMLFormElement>) => this.handleSubmit(e)}>
            <label>Referee Name</label>
            <input onChange={(e:React.ChangeEvent<HTMLInputElement>) => this.onScorerChange(e)}/>

            <label>Select Table</label>
            <Select onChange={(e:SingleValue<SelectOption>) => this.onTableChange(e)} options={this.state.tableOptions}/>

            <div>
              <button className="buttonGreen" type="submit">Submit</button>
            </div>
          </form>
        </div>
      );
    } else {
      return(
        <div className="waiting-message">
          <div className="loader"/>
          <h2>Waiting for Event Data</h2>
        </div>
      )
    }
  }
}