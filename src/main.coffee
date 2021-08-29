

'use strict'


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'RUNAWAY-REGEX-TEST/MAIN'
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
info                      = CND.get_logger 'info',      badge
urge                      = CND.get_logger 'urge',      badge
help                      = CND.get_logger 'help',      badge
whisper                   = CND.get_logger 'whisper',   badge
echo                      = CND.echo.bind CND
#...........................................................................................................
test                      = require 'guy-test'
jr                        = JSON.stringify
#...........................................................................................................
# PD                        = require 'pipedreams'
# { $, $async, }            = PD
#...........................................................................................................
# sre_1                     = require 'safe-regex'
sre_2                     = require 'safe-regex2'
Re2                       = require 're2'
{ to_width
  width_of }              = require 'to-width'


#.........................................................................................................
match_against_re = ( n, text, re ) ->
  t0    = process.hrtime()
  # text.match re for _ in [ 1 .. n ]
  # re.test text for _ in [ 1 .. n ]
  re.exec text for _ in [ 1 .. n ]
  t1    = process.hrtime()
  t0bi  = BigInt "#{t0[ 0 ]}#{"#{t0[ 1 ]}".padStart 9, '0'}"
  t1bi  = BigInt "#{t1[ 0 ]}#{"#{t1[ 1 ]}".padStart 9, '0'}"
  return ( parseInt ( t1bi - t0bi ), 10 ) / 1e6

#.........................................................................................................
match_against_re2 = ( n, text, re ) ->
  t0    = process.hrtime()
  # text.match re for _ in [ 1 .. n ]
  # re.test text for _ in [ 1 .. n ]
  re.exec text for _ in [ 1 .. n ]
  t1    = process.hrtime()
  t0bi  = BigInt "#{t0[ 0 ]}#{"#{t0[ 1 ]}".padStart 9, '0'}"
  t1bi  = BigInt "#{t1[ 0 ]}#{"#{t1[ 1 ]}".padStart 9, '0'}"
  return ( parseInt ( t1bi - t0bi ), 10 ) / 1e6

#-----------------------------------------------------------------------------------------------------------
@[ "regex performance, runaway test" ] = ( T, done ) ->
  probes_and_matchers = [
    ['^number',true,null]
    ['^numberfgasiufdgaskjfgasjgfalsgfjadgfjgfajsgfjsgdfajsdfjasgdfhasgdfhas',true,null]
    ['<numberfgasiufdgaskjfgasjgfalsgfjadgfjgfajsgfjsgdfajsdfjasgdfhasgdfhas',true,null]
    ['^73982749823423j4hk2hdakjsdhasiuzdfiuwzrwjhfdkjasbdf',true,null]
    ["^prfxsjfskjfgiwefskjfszwre:foorweizowrzeruwerwmebrmwerwr<yxh<",true,null]
    ["<prfxsjfskjfgiwefskjfszwre:foorweizowrzeruwerwmebrmwerwr<yxh<",true,null]
    ["tzieuztksdhfjxdlkjasgfagsdjagsdlkfjahsdkga:yjgfhgdfyajdgkajgkjgrrr",true,null]
    [">prfxsjfskjfgiwefskjfszwre:foorweizowrzeruwerwmebrmwerwr<yxh<",true,null]
    ["<>prfxsjfskjfgiwefskjfszwre:foorweizowrzeruwerwmebrmwerwr<yxh<",true,null]
    ["<>^prfxsjfskjfgiwefskjfszwre:foorweizowrzeruwerwmebrmwerwr<yxh<",true,null]
    ["^<>",true,null]
    ["#stamped",true,null]
    ["#stampedashfisfiuhsdfkjskdfkjsf",true,null]
    ["aaaaaaaaay",true,null]
    ["aaaaaaaaaaaaa",true,null]
    ["aaaaaaaaaaaaab",true,null]
    ["xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxy",true,null]
    ["xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxyxxxxxxxxxxxxxxxxxxxxxxxyxyxyyxyxyxyx",true,null]
    ]
  #.........................................................................................................
  n         = 1e4
  patterns  =
    simple:         /[aeiou][^aeiou]/
    # datom:          PD._datom_keypattern
    # selector:       PD._selector_keypattern
    # tag:            PD._tag_pattern
    catastrophic1:  /(a+){10}y/
    catastrophic2:  /(x+x+)+y/
    catastrophic3:  /(a+)+$/
    catastrophic4:  /(a|a)+$/
    # catastrophic5:  /(.*){1,10}[bc]/ ### too bad, neverr finishes ###
  dtA_sum = 0
  dtB_sum = 0
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      for key, re of patterns
        re2 = new Re2 re
        #...................................................................................................
        dtA       = match_against_re  n, probe, re
        dtB       = match_against_re2 n, probe, re2
        dtA_sum  += dtA
        dtB_sum  += dtB
        # dtB = 1000
        rel = dtB / ( Math.max dtA, 1e-3 )
        #...................................................................................................
        dtA_txt = ( to_width ( dtA.toFixed 3 ), 10, { align: 'right', } )
        dtB_txt = ( to_width ( dtB.toFixed 3 ), 10, { align: 'right', } )
        rel_txt = ( to_width ( rel.toFixed 3 ), 10, { align: 'right', } )
        rel_txt = ( if dtB > dtA then CND.red else CND.green ) rel_txt
        #...................................................................................................
        debug 'µ34322', ( to_width key, 20 ), dtA_txt, dtB_txt, rel_txt
      resolve true
  debug 'µ22311', "dtA_sum", dtA_sum / 1000
  debug 'µ22311', "dtB_sum", dtB_sum / 1000
  done()
  return null

#-----------------------------------------------------------------------------------------------------------
is_valid_Re2 = ( pattern_or_regex ) ->
  try
    new Re2 pattern_or_regex
    return true
  catch error
    return false

#-----------------------------------------------------------------------------------------------------------
@[ "basic" ] = ( T, done ) ->
  probes_and_matchers = [
    [[ 'simple',     /[aeiou][^aeiou]/],[true,true,],]
    # [[ 'PD/datom',      PD._datom_keypattern],[true,true,],]
    # [[ 'PD/selector',   PD._selector_keypattern],[true,true,],]
    # [[ 'PD/tag',        PD._tag_pattern],[true,true,],]
    [[ 'x1', /(a+)+$/, ], [false,true,], ]
    [[ 'x2', /(beep|boop)*/,], [true,true,], ]
    [[ 'x3', /\blocation\s*:[^:\n]+\b(Oakland|San Francisco)\b/,], [true,true,], ]
    [[ 'x4', /(x+x+)+y/,], [false,true,], ]
    [[ 'x5', /(a+){10}/,], [false,true,], ]
    [[ 'x6', /(a+){10}y/,], [false,true,], ]
    [[ 'x7', /(.*){1,320}[bc]/,], [false,true,], ]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      [ key, pattern, ] = probe
      # debug ( CND.truth sre_1 pattern ), ( CND.truth sre_2 pattern ), ( CND.truth is_valid_Re2 pattern ), key
      # is_safe = ( sre_1 pattern ) and ( sre_2 pattern )
      is_safe = !!( sre_2 pattern )
      is_re2  = ( is_valid_Re2 pattern )
      result  = [ is_safe, is_re2, ]
      resolve result
    # debug new Re2 /.(?=a)/
  done()
  return null




############################################################################################################
unless module.parent?
  test @
  # test @[ "regex performance, runaway test" ]
  # test @[ "selector keypatterns" ]
  # test @[ "select 2" ]
  # x = BigInt '123456'
  # y = BigInt '123456'
  # debug x * y
  # debug x ** BigInt 123
  # t0    = process.hrtime()
  # t1    = process.hrtime()
  # t0bi  = BigInt "#{t0[ 0 ]}#{"#{t0[ 1 ]}".padStart 9, '0'}"
  # t1bi  = BigInt "#{t1[ 0 ]}#{"#{t1[ 1 ]}".padStart 9, '0'}"
  # debug t0bi
  # debug t1bi
  # debug parseInt ( t1bi - t0bi ), 10

