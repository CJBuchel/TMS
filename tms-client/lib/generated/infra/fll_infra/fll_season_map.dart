// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.2.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../frb_generated.dart';
import 'fll_game.dart';
import 'mission.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'question.dart';
import 'seasons/fll_2023.dart';


            // These functions are ignored (category: IgnoreBecauseExplicitAttribute): `get_fll_game`


            

            
                // Rust type: RustOpaqueMoi<flutter_rust_bridge::for_generated::RustAutoOpaqueInner<FllGameMap>>
                abstract class FllGameMap implements RustOpaqueInterface {
                     int  calculateScore({required FllGame fllGame , required List<QuestionAnswer> answers });


static List<BaseSeason>  getGames()=>TmsRustLib.instance.api.crateInfraFllInfraFllSeasonMapFllGameMapGetGames();


 List<QuestionValidationError>?  validate({required String season , required List<QuestionAnswer> answers });



                    
                }
                
            