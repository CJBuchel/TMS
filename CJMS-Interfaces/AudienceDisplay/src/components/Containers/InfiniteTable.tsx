import React, { Component, useRef } from 'react'
import "../../assets/application.scss";
import "../../assets/InfiniteTable.scss";

const DEFAULT_SPEED = 1;
const DEFAULT_DELAY = 1000;

interface IProps {
  headers:any;
  data:any;
}

interface IState {
  scrollTop:number;
  table_body:any;
}

export default class InfiniteTable extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      scrollTop: 0,
      table_body: React.createRef()
    }

    this.scrollCallback = this.scrollCallback.bind(this);
  }
  
  unmountScroll = false;

  scrollCallback() {
    if (!this.unmountScroll) {
      this.setState({scrollTop: this.newScroll(this.state.scrollTop)});
      window.requestAnimationFrame(() => this.scrollCallback());
    }
  }

  componentDidMount() {
    this.unmountScroll = false;
    setTimeout(() => window.requestAnimationFrame(() => this.scrollCallback()), DEFAULT_DELAY);
  }

  componentWillUnmount() {
    this.unmountScroll = true;
  }

  bodyScrollHeight() {
    return this.state.scrollTop + this.state.table_body.current?.scrollHeight || 0; // document.body.scrollHeight
  }
  
  isScrolling() {
    return window.innerHeight < this.bodyScrollHeight() ? true : false;
  }

  newScroll(oldScroll:number) {
    const height = this.bodyScrollHeight();

    if (!this.isScrolling()) {
      return 0;
    } else if (oldScroll >= height/3) {
      console.log("Resetting");
      return (oldScroll - height/3);
    } else {
      // console.log("scrolling");
      return oldScroll + (DEFAULT_SPEED/2);
    }
  }

  getFormattedData(data:any) {
    const content:any[] = [];
    for (const row of data) {
      const columns:any[] = [];
      for (const column of Object.keys(row)) {
        columns.push(<td>{row[column]}</td>);
      }

      content.push(
        <tr key={row.Team}>
          {columns}
        </tr>
      );
    }

    return(
      content
    );
  }

  getFormatedHeaders(headers:any[]) {
    const content:any[] = [];
    for (const header of headers) {
      content.push(<th>{header}</th>);
    }

    return (<tr>{content}</tr>);
  }

  renderTable() {
    const firstTable = this.getFormattedData(this.props.data);
    const secondTable = this.getFormattedData(this.props.data);

    const scrolling = this.isScrolling();

    if (scrolling) {
      return(
        <tbody id='table-body' ref={this.state.table_body}>
          {firstTable}
          {secondTable}
        </tbody>
      );
    } else {
      return(
        <tbody id='table-body' ref={this.state.table_body}>
          {firstTable}
        </tbody>
      );
    }
  }

  render() {
    return (
      <div id='table-wrapper' className='table-wrapper' style={{direction: 'ltr', marginTop: -this.state.scrollTop}}>
        <table id='table-parent' className='fl-table ui scrollable single line very basic compact table'>
          <thead id='table-head'>
            { this.getFormatedHeaders(this.props.headers) }
          </thead>
          { this.renderTable() }
        </table>
      </div>
    );
  }
} 