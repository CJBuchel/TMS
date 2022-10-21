import { IEvent, ITeam, ITeamScore } from "@cjms_shared/services";
import { Game, ScoreAnswer } from "ausfll-score-calculator/dist/game-types";
import Calculator from "ausfll-score-calculator";
import { Component } from "react";

import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { CJMS_REQUEST_EVENT } from "@cjms_interfaces/shared";

import "../../../../assets/TeamEdit.scss";
import TeamEditValues from "./TeamEditValues";

interface IProps {
  selected_team?:ITeam;
}

interface IState {
  graph_data:any[];
  game:Game;
}

const bright_hex = [
  '#ff000d',
  '#66ff00',
  '#0165fc',
  '#fe6700',
  '#fffd01'
]

export default class TeamEdit extends Component<IProps, IState> {
  constructor(props:any) {
    super(props);

    this.state = {
      graph_data: [],
      game: Calculator.Games[0]
    }
  }

  setGame(event:IEvent) {
    const game:Game = Calculator.Games.find(e => e.season === event.season) || Calculator.Games[0];
    this.setState({game: game});
  }


  setScoreArray() {
    this.setState({graph_data: []});
    if (this.props.selected_team) {
      var graph_array:any[] = this.state.game.scores.map(score => score);

      // console.log(graph_array);
      for (const round of this.props.selected_team.scores) {

        if (round.scoresheet.answers.length > 0 && round.valid_scoresheet) {
          for (const score of round.scoresheet.answers) { // answers
            const single_score_scoresheet:ScoreAnswer[] = [score];
            Object.assign(graph_array.find(e => e.id == score.id), {
              round: String(round.scoresheet.round),
              [round.scoresheet.round]:this.state.game.score(single_score_scoresheet)
            });
          }
        }
      }


      // console.log(graph_array);
      this.setState({graph_data: graph_array});
    }
  }

  componentDidUpdate(prevProps: Readonly<IProps>, prevState: Readonly<IState>, snapshot?: any): void {
    if (this.props != prevProps) {
      this.setScoreArray();
    }
  }

  async componentDidMount() {
    CJMS_REQUEST_EVENT().then(event => {
      if (event) {
        this.setGame(event);
        this.setScoreArray();
      }
    });
  }

  randomInt(min:number, max:number) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
  };

  getColorCode(value:number) {
    if (value-1 < bright_hex.length) {
      return bright_hex[value-1];
    } else {
      var h = this.randomInt(0, 360);
      var s = this.randomInt(42, 98);
      var l = this.randomInt(40, 90);
      return `hsl(${h},${s}%,${l}%)`;
    }
  }

  getChart() {
    if (this.state.graph_data.length > 0) {
      return (
        <ResponsiveContainer key={this.props.selected_team?.team_number} width='100%' height='40%'>
          <LineChart key={this.props.selected_team?.team_number} data={this.state.graph_data} margin={{top: 30, right: 30, left: 20, bottom: 5}}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="id" />
            <YAxis color="white" />
            <Tooltip />
            <Legend />
            
            {this.props.selected_team?.scores.map(round => (
              <Line
                key={round.scoresheet.round}
                type="monotone"
                dataKey={round.scoresheet.round}
                name={`Round ${String(round.scoresheet.round)}`}
                stroke={this.getColorCode(round.scoresheet.round)}
                strokeWidth="2px"
                activeDot={{ r: 8 }}
              />
            ))}
          </LineChart>
        </ResponsiveContainer>
      );
    }
  }

  render() {
    if (this.props.selected_team) {
      return(
        <div className="team-edit">
          {this.getChart()}
          <TeamEditValues selected_team={this.props.selected_team}/>
        </div>
      );
    } else {
      return (<></>)
    }
  }
}