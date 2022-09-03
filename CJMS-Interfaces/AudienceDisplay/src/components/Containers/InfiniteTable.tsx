import React, { Component } from 'react'
import "../../assets/InfiniteTable.scss";

const DEFAULT_SPEED = 1;
const DEFAULT_DELAY = 1000;

interface IProps {}

interface IState {
  scrollTop:number;
}

export default class InfiniteTable extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      scrollTop: 0,
    }
  }

  componentDidMount() {
    setTimeout(() => window.requestAnimationFrame(() => this.scrollCallback()), DEFAULT_DELAY);
  }

  newScroll(oldScroll:any) {
    const height = document.body.scrollHeight;

    if (oldScroll >= height/2) {
      return oldScroll - height/2;
    } else {
      return oldScroll + (DEFAULT_SPEED);
    }
  }

  scrollCallback() {
    this.setState({scrollTop: this.newScroll(this.state.scrollTop)});
    window.requestAnimationFrame(() => this.scrollCallback());
  }

  renderTable() {
    const content:any[] = []
    for (var i = 0; i < 30; i++) {
      content.push(
        <tr>
          <td>{i}</td>
          <td>Yay</td>
          <td>Yay</td>
          <td>Yay</td>
          <td>Yay</td>
        </tr>
      );
    }


    return(
      <tbody>
        {content}
      </tbody>
    );
  }

  renderScroll() {

  }

  render() {
    return (
      <div className='infiniteTable' style={{direction: 'ltr', marginTop: -this.state.scrollTop}}>
        <table>
          <thead>
            <tr>
              <th>Rank</th>
              <th>Team Name</th>
              <th>Round 1</th>
              <th>Round 2</th>
              <th>Round 3</th>
            </tr>
          </thead>
            { this.renderTable() }
        </table>
      </div>
    );
  }
} 