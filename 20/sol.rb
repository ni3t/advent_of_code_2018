V = ARGV.delete('-v')

(
TESTDATA1 = <<TEST.freeze
^WNE$
TEST
)

TESTDATA2 = <<TEST.freeze
^ENWWW(NEEE|SSE(EE|N)$
TEST

TESTDATA3 = <<TEST.freeze
^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$
TEST

TESTDATA4 = <<TEST.freeze
^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$
TEST

#-# # #-# # #-# # #-## #
#                      #
#   # # # # #   # # #  #
#   #       #   #   #  #
#   #   # # #   #   #  #
#   #   #       #      #
#   #   #   # # # # #  #
#   #   #   # 1     #  #
#   #   #   # # #   #  #
#       #       #   #  #
# # #   #   # # #   #  #
#       #           #  #
# # # # # # # # # # ## #

TESTDATA5 = <<TEST.freeze
^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$
TEST

# # # # # # # # # # # # # # #
#               #           #
#   # # #   # # #   #   #   #
#       #           #   #   #
#   # # # # # # # # #   #   #
#   #                   #   #
#   #   # # # # # # # # #   #
#   #   #     1 #       #   #
# # #   #   # # #   #   #   #
#       #   #       #       #
#   # # #   # # # # #   # # #
#       #           #   #   #
#   #   # # # # #   #   #   #
#   #               #       #
# # # # # # # # # # # # # # #

INPUT = (ARGV.include?('-t') ? TESTDATA5 : ARGV.empty? ? DATA : ARGF).each_line.first.chomp.split("")
INPUT.shift && INPUT.pop

NODE_ID = 1.step

DIRS = {
  ?N=>[0,-1],
  ?S=>[0,1],
  ?E=>[1,0],
  ?W=>[-1,0]
}
Node = Struct.new(:x,:y,:id,:downstream)
Graph = Struct.new(:nodes) do
  def add_node(input, from)
    x,y = [from.x+DIRS[input][0],from.y+DIRS[input][1]]
    node = Node.new(x,y,NODE_ID.next.to_s,[])
    node_in_history = nodes.select{|n| n.x==node.x && n.y==node.y}
    if !node_in_history.any?
      self.nodes << node
      from.downstream << node 
    end
    node
  end
  def longest_path
    @current_nodes = [nodes.first]
    @length = 0
    until @current_nodes.empty?
      @current_nodes = @current_nodes.map(&:downstream).flatten
      @length += 1
    end
    @length - 1
  end
  def longer_than_thousand
    @current_nodes = [nodes.first]
    @length = 0
    @longer = []
    until @current_nodes.empty?
      @current_nodes = @current_nodes.map(&:downstream).flatten
      @length += 1
      @longer.concat(@current_nodes.flatten) if @length >= 1000
    end
    @longer.count
  end
end

@initial_node = Node.new(0,0,NODE_ID.next.to_s,[])

@graph = Graph.new([@initial_node])

@from_node = @initial_node
@split_nodes = []
INPUT.each_with_index do |input,index|
  if @split_nodes.any?
    if input == ?|
      @from_node = @split_nodes.last
    elsif input == ?)
      @from_node = @split_nodes.pop
    elsif input == ?(
      @split_nodes << @from_node
    else
      if [?N,?S,?E,?W].include?(input)
        @from_node = @graph.add_node(input, @from_node)
      end
    end
  else
    if [?N,?S,?E,?W].include?(input)
      @from_node = @graph.add_node(input, @from_node)
    elsif input == ?(
      @split_nodes << @from_node
    end
  end
end

puts @graph.longest_path
puts @graph.longer_than_thousand

__END__
^NWSWSWSWNWSWSWWWSWNWWSESEESWSWNWWWNNE(SEWN|)NNNNWNEEENESSWWSSEEN(ENNNNWWNEENESEEEEESES(WS(SWNNNWWWWSSSEE(SWWS(E|W)|ENNWWSE(WNEESSNNWWSE|))|E)|ENNWNNNENWNENESESWSESSSESESESESWWSEEESESEESWSWSWSWSWSEENEESSSSESSSSWWWWNENNWWWWNEEEENWWN(EEE(N|SSSSSENN(SSWNNNSSSENN|))|WWWS(EE|WSWWWNNNWSWWNENEENNWNWSS(E|WWW(SSWSSWWWSSWSWSSWNNWNEENNE(NEENN(WNWSS(E|WWS(E|SWS(E|WWWSSEE(NWES|)SSE(N|SSSWWWNNE(SENSWN|)NNWSWNNNWNNNWSSWSWNNWWSSSE(ESWSSESWWWSEESWSSSESESENEESENNNENN(WSWNWSWNW(SWSESENEESW(ENWWSWENEESW|)|NENNN(W|EE(NWWNE(N|E)|SSW(SEENNSSWWN|)N)))|EEESENEEENNNNEEEESESSEESEESSSENESSWSSWNWWNNWWSESSSWSEESEEEEEESSSSSSWWNNWWNEEE(SS|NNWSWWWWSESWWWWWNNWWNENNWNENNWSWWWSEESWSSE(NEWS|)SWWSSSWSSESWWNNNWSSWWWSESSENE(NWES|)SSSSENEESEENWNWWWNEN(EES(W|ENNESSENEESWSEEEEEEEESWWWWSEEEESEENWNEEESEESSESEENESESSSSESSEENWNNWNNEENNWNWNWNWNWWWS(WNW(NEEENWWWNNNWW(SWSWNWWWNN(ESNW|)WSSWWWNEENWWWSSS(ESES(W|EEEEEN(ESEEN(W|E(SSWWWEEENN|)N(W|N))|WN(E|WSWNW(W|S))))|WNW(S|WWNENNN(WWSESWS(W|SS)|ESSSEN)))|NENNW(S|NNEEENENWNWNENWWSWWSWW(NEN(W|NEE(SWEN|)NENENNNWNEEN(WNNWSWS(WWNWSSWWNENNWNEN(WWWNWSWWN(NNE(NNEWSS|)S(EEESNWWW|)S|WSSEEESS(WNWWWWW(NENE(NWES|)S|WSSWWSSENES(NWSWNNSSENES|))|EE(NNWSNESS|)(SWS(WNSE|)ESEEEENESE(N|SS(ENSW|)WNWWS(WNSE|)ESE(SWEN|)E)|E)))|ESSEE(EN(WN(WSNE|)N|EEE)|S))|E)|ESSSW(SESENEESENEENNWSWNWWW(SEEWWN|)NEN(ESEENEENNWNEEESENNNWWWWWW(SSSE(S(WSNE|)E|NNEEEE)|NENNWNW(NW(NEEN(W|ENENNWSW(NWWNWNWNNNW(S|NNWNWW(SESESNWNWN|)NENNNW(SS|NW(S|WWWSWSWSWNNENENNNWSWS(SWNNWNNNENENESEENNNNNEENNWWNNNNNWWWSEESSSWNWN(E|WNNNNNNNENWNWNEENENNNENNESSSWSSEEN(W|EENWNW(NENESSEENNENNWWWNWSWWS(WNNNESENN(WWWWWSWNWWWWWWSEEEEESESWSSESESWSES(ENNNNNW(W|S|NNESE(NNWESS|)SSS)|SWNWWSWWWWNEENNNNWNEEE(SWSSS(S|EENNWS)|NNWSWNWWWWWNN(ESENSWNW|)WWSWWN(E|WWSESEEESSSESSESWSWSWSESSWWN(E|NNNNWSSWSESSWWN(NWWNENNENE(SSWSNENN|)NENENWWSWSWNNNWWNWSSSSSSSSSE(NNNNNE(NNWSNESS|)S(E|SS)|SWWSWSSEEEESESWSEENEESSESENNENESSSW(SESENNNNNNWNN(WSSWNNWSS(WWNN(ESNW|)WS(S|WNWWN(EENW|WSW))|S(S|E))|NESENNEN(WWN(WSSEWNNE|)NESENNWNNWNENEE(SSESW(WNN|SE)|N(E|WWWSWNNN(SSSENEWSWNNN|)))|ESENEEEE(N|SSWSWWN(NE(E|S)|WWSSSEEN(WNSE|)ESEEN(NE(N|SSSWWWSSWSESEESE(ESWWWNWSSSWNNNWWSWW(WWWSWSWNWNENWWWWWNNN(WSSWWNNE(NNE(NWWWSESWWWNNNNE(SSS|NNWWS(WSSE(N|SWWWSSENESE(SWWWWSSSEEESENENWWWN(WSNE|)EEENESSSSSSENEENN(ESSSENNEEESSESESSWNWWWN(NNESSE|WSWNWSSSWWSWSWWWSEESESSESWSSSWSSESWSWSSWSWNNWWSESWWNWWNENE(NNEESES(WWNSEE|)E(S|NENWNENNWNWWSES(S(S|WWN(NWSWS(E|WSWNNWSSWWSWNWSSSESSWWWWSESSWWSW(NNNE(SEWN|)NNENENWNENWNWNEEENWWNENNNWWSS(ENSW|)W(SS(ENSW|)SSSESSW(N|S(E|SS))|NNNNNEEENNNENNENEEESWSSSSWWN(ENN(WSNE|)N|WSSSESSEEESSWSES(SWWS(W(NNE(NNN(E|WSSWNNNNWNWWSE(WNEESEWNWWSE|))|E)|W(W|SSSSS(W|E)))|EE)|EENNW(NENWNENENNWSWSWWN(ENNNES(S|ENEENWWW(NENEEENWNNNWWWSWWWWWSS(SWWSWSW(NNNNEES(WSNE|)ENNNNNEENWNEEENWNEESENNESSENNNWNENENWNEENEEESSWNWSSEES(WSSWS(EENNSSWW|)WNNW(SSSEESSWWSES(WWWNENN(EE|WWS(SSWSWNNN(WSSSWWNE(WSEENNSSWWNE|)|E(S|N))|E))|SSSESENESEEE(N|SSEESE(NNEWSS|)SWWNWSWNNNWSSSSS(EEN(E|W)|WNNWSSSESWWSEESWSES(WWSWNNWSSW(S(S|E)|NNNNENE(SS(ESNW|)W|NNN(NE(SSS|NWN(WW|EEE(SW|NWW)))|W(SS|W))))|EESE(NNWN(W(NEWS|)S|E)|S)))))|NE(ESNW|)NN)|ENNENESS(W|ENNESS(ENNNWWNWSWNW(SS|NNNNWSSWWNENWNNEN(EEESENESENEES(EEEN(WW|ESS(S(S|E(EEESSSS(E(SWSNEN|)N|W(W|N))|N))|WW))|WSWWWSESWSES(ENE(NNWS|SSW)|WWNNNNWW(NEWS|)W))|WWSSWNNWWWWSWWWN(EE|WSSEEESSENNEEE(NWWEES|)SEESSWSS(SWNWWWWNWN(NWWN(WNNNWSSWW(NNESNWSS|)SSEE(NWES|)ESWSWNWSSESSSENNESSEESEESSS(WWWSS(ENSW|)WWSESWSWW(NNE(S|NWNNENNN(EESE(N|S(EENWESWW|)WW(SESWWEENWN|)N)|W(NNN|SS)))|SSEE(SWW|NW))|ENENNNNE(NWWWSS(E(SS|N)|WNNWW(SEWN|)NN(WSW|NESSE))|SS))|EE)|EESEEENWN(NWSSNNES|)EE)|EEEN(ESNW|)WW))))|S)))|SSSENNE(NENSWS|)SS)|EEEEE(S|N(ESENNW|WWWW)))|W))|W(SSEEWWNN|)W)|S))))|SSSESSW(N|SSEEENEENWWW(SWEN|)NEENNWSWNWNEEN(W|ENESEESWW(W|SSES(SSSEENEESWSWWWSSSWWSWNNEENWN(NESNWS|)WWWWSEE(SWSSE(N|SSESWWNW(N(E|NNN)|SSEEEENNN(W|ENESSWSSEEN(W|ENWNEEEENESSWSSWW(NENWESWS|)SESWWN(N|WSSSSSSSWNNNNNNNWSSWNNWWWSSSSW(SESENNNNE(NWES|)SEESSSSWSEEEEEENNNEEENWNEEEEENWNEEENWWNWNWWNW(SSSEE(NWES|)(SWWWW(NENNSSWS|)S(WSWNWSSE(EENSWW|)SSW(SEWN|)N|EEEE)|E)|NNNEENEESSW(WWSESENESSENNESENESENNNWWNENWWW(WNNNESSEENWNNESENEESSES(WSW(NN(WSNE|)N|SESSSESSW(N|WSSWSW(SSSWSESSENEESESEN(NWNWNNWW(NEENW|SSEN)|ESSSESWWNNWSWNNW(SWNWWWWSSSSENNNESSSSEEEESWSWWSWNWN(EEE|WSSSWNWSSSSSWWSESWWNWSWWWWSWWWWNENENENWNNWWWSSWW(NNE(S|NNEEENWWWW(NEEENENWNWNWSSS(ENSW|)WNNNNNN(N|EEE(NENWNE|SWS(WNSE|)ESEES(W|SENNEN(WWW|ESESSENENWN(W|EEENWWNNEEEEES(WSESSWNW(NNWWEESS|)SWSESENESS(WSS(ENSW|)WSSWNNWNEN(ESNW|)NW(SW(WSWSEE(N|SESSEESWS(WSWWSWWNW(SWSWENEN|)NNWNENESENN(WNNN(E|NW(NEWS|)SSWNWS(SES(ENSW|)SW(N|WWW)|W))|ESSE(N|S(WS(W(WNEWSE|)S|E)|E)))|E))|N)|NN)|EE)|EEN(ESNW|)WNEN(NNESNWSS|)WWSWWNE(WSEENEWSWWNE|)))))))|SS))|SEES(ENENWNE(WSESWSNENWNE|)|SSSSWSSW(NNNENWNENW(ESWSESNWNENW|)|SSSSENEES(ENNEENENWNWNEN(EESS(WNSE|)ENNESSEENESSWWWWWSSESENEN(WW|ESSS(W(N|WWWNW(SWWNEWSEEN|)N)|ENNESES(EENESEENWNEEEESS(WNWSNESE|)ENNNNWNWSWWS(WWSWW(NW(S|NNNW(SSSWENNN|)NEESESWSE(EENNNEENWWNNESENENEENNWSWNNNN(WSWSSE(SWS(WNNNW(N(E|N)|WWSESSW(SSW(N|S(WWWS(W(NWWWEEES|)S|E)|EEE(S(W|SS)|NWNENNN(SSSWSEWNENNN|))))|N))|E)|N)|ENENNEN(WNWSWWWNEENWWN(SEESWWEENWWN|)|ESESEEENNNENNNENW(WWSESWW(WNEN(W|N)|SSE(NEWS|)SW(SEWN|)W)|NEENNN(EEESEES(WWWW(NEWS|)SE(EEE|SWSESSWSWW(NEN(NN|E|W)|SWSSSE(SWWNWSSSSESWSWNWSWNNW(NEEE(SWEN|)NWWWN(WSSWNSENNE|)NE(SEENW|NW)|SSSEEEESWWWSWWN(E|NWSSSS(ENESS(SEESWSSW(NN|SEEENWNENNESESWSSEEN(ESENESEEEENWNENWWWS(ESWENW|)WNNNNWNWN(NWSW(WSSES(WWNWN(WSSE|NES)|SEESWSEENNNWNW(NWES|)S)|NNNEESW(ENWWSSNNEESW|))|EESEN(N|ESSSS(WNNSSE|)EENWNNNESSENEESSENNNNN(WWSESWWNNN(W|E)|ESSSESSW(SSENEESWSSS(ENNESSEEEENNWNNNESENNESESWSW(SSSEENENESENNENE(SSWSEESWWWWW(EEEEENSWWWWW|)|NWWSWW(S(WSWSNENE|)E|N(NWNWN(E|W(N|SWWWWNWWW(WNNSSE|)SSEE(NWES|)ESE(NEEWWS|)SSSW(SEEWWN|)NWN(NWWEES|)E))|E)))|W)|WNWSWWNWNNEN(ESS(EE|S|W)|WW(NEN|SSSSE)))|N))))|W))|W)|W(WWSEWNEE|)NNN)))|NNEES(W|ENN(NENNSSWS|)WW))))|ENEES(W|SE(NNNNWSWWWWN(EEENENN(ESSEESES(WWNSEE|)E(SSEWNN|)N|WW(NEEWWS|)S(S|E))|W)|S(ENSW|)WSSE(N|SWSEESS(WNSE|)ENN(NWES|)EEEE))))|NWSSSWN(SENNNEWSSSWN|)))))|S))|S)|EEE)|W)))|WWWSSE(N|SS(ENSW|)WW(N(E|N)|S(WNSE|)E)))|W)))))|N))|NNENWWSW(ENEESWENWWSW|))))|ENNWNEEENNNNWNNWWWWSSWNWWNENE(NNEESEENNW(S|WNNNWSW(WSS(EENWESWW|)SW(WSWWWWWSSWNWSSSESSWSS(WNWSWW(NNN(ENEE(NNNNN(EESWENWW|)WWSESSW(SEWN|)WN(E|N(NNENN(EE(SSWNSENN|)EN(ENSW|)WWW|W(S|W))|WS(WNWSNESE|)S))|S(WS(WSNE|)E|E))|W)|S)|ESEESSES(ENNWNNNNESEE(SWWSNEEN|)ENNE(ESWSEEEENNE(NWN(E|WSSSWN)|SE(SWEN|)N)|NWWNNWSSS(SENSWN|)WWWW(NEN(WW|NESE(SWEN|)NN(EEENEWSWWW|)WW)|SESSWNW(ESENNWESSWNW|)))|WWNNWW(N|SESWW(N|WWWSEESE(SWWWNE|NEE(SWEN|)EE)))))|NN)|NNEEESEEESENENNNESEESESESSSEEEE(NNEENNWNWNNNENNNWNNESESESE(NNWNWNEE(NNEE(SWSNEN|)EEE(NWNWNENN(W(N|WS(SSS(WNWWS(E|SWWWSE(EE|SWWNNWNNESENN(NN(N|WSWNWWSES(WWSESWSESWSEEN(ESSSE(N|SWSWWSWWNWNENN(WNWSWNWWWNENN(ESES(EEE(S|NW(W|NNNE(NENSWS|)SS))|W)|WWWSE(SSSWNWSSESSENNEEE(NWWEES|)SWWSEEEE(NWNEEWWSES|)SSS(EN(EESENENESSE(NNENWESWSS|)SWSSW(SSSENNE(N(ESEWNW|)N|SS)|WNWN(W(N|W)|EE(S|N)))|N)|WWSSSWNNNWSSSWNWWNWW(NEN(NE(NWN(E|NW(S|N(NE(NEEWWS|)S|W)))|SSENNEEEES(ENSW|)WWWSSW)|W)|S(E|W)))|E))|ESS(S|ENNESS)))|NNN)|EE))|ESSENNEEENWN(WSNE|)E)))|E)|E))|ES(EE|SS))|S)|S)|SSWW(SESW(WNSE|)SESSENNEE(NNW(WSEWNE|)NN|SWSSEEEENN(N|WWS(E|W)))|N(N|E)))|SWWWSSWSEESSWNWWWSEESWWSESWSSENEE(ESWWSSWSWWW(NEEN(WNWNENWNNE(NWNNNNNWSSSSSW(NWNENNWW(S(WWWWNSEEEE|)E|NEENWWN(NWWSEWNEES|)EEEEN(W|ESEN(NWWNEWSEES|)ESSSESWSWW(NNE(NWWWEEES|)S|S(S|EE))))|SESSW(N|SSE(N|S(E|WWNWSSES(NWNNESNWSSES|)))))|S)|E)|S)|NN(WSNE|)N))))|S))|SESS(WNSE|)EE)|N))|NNNN))))))|E)|W))))))|E))|E))|S))|WSWNNNN(SSSSENSWNNNN|))|N))|E))|S)|S)|EESWSEEE(NWNNSSES|)EES(E|S))|NENENNWSW(S|NNEEN(EESWSSSE(WNNNENSWSSSE|)|WNW(N(ENNSSW|)W|S))))|NNNNWSW(SEWN|)N))|W)))))|N))|E)))))|ESEEEN(EESWS(WW|EESENNWNEESSEEENWWNEEEEEESSWWSW(NNEEWWSS|)WWSWW(NEWS|)SSWSSSWWNNN(E(SS|NN(ESNW|)W(N|S))|WSSSWNWSSWSW(SWNWWSESESENEEEEESSWSESSENNESESWSSWWSWNWWWSSENESSSESSSWNWSSSSENEN(W|ENESSSESEENNW(S|NW(S|NNWWNNNEN(WWSNEE|)EN(W|ENESENNW(W|NNNNNNNESESWSEENENESENEESSW(WWSESWWWN(ENSW|)WSS(WNNSSE|)SSENEN(ESESWWSWWSESSWNWWSESWW(WN(WSNE|)NE(NEEWWS|)S|SES(W|SENEN(NESSENEEESWSW(WWSEESWSESWSSWNWSWSWWSWNWNEEENWWN(EEE(NNE(SSENNSSWNN|)N(W|N)|S)|WSWWWNEEN(N(N|WSWWSSWNNWSW(WWS(WW(WSE|NE)|EEESEESS(ENEE(NWWEES|)SESSENEEESWWSESEESSWNWWNWNWWSESS(E(N|EESSESWWSEESWW(WNNNWNEES(NWWSESNWNEES|)|SEEES(ENEEEESWWWSSENEESWSSENEEENNEEENESESSENNEEENESSSEESWWSEESSWSEENESSWSWWN(E|WSWNWWNEEENWWWWSSSWNWSSESWSSWNNNWWWWNEEENWNNWSSWWS(SSSEEESWWSEEE(NNNWWW|ESWSWWN(WSSWSESEENESSSSWSESSWNWNWSSWNNNWSWNNENN(NWSWNW(NEENNEE(SWSNEN|)N(N|WWW(SSWWEENN|)N)|SSE(SWWNWSWSSWSWWW(NNEN(WW(SW(W|N)|N)|E(ESWSWENENW|)N)|SESEEEEESEESEENWNWNN(ESE(SESSENESSWWSSWWSWWWSWNWWSSE(ESSWNWSS(EEESEEEESWWWS(WNWNWESESE|)EESSSW(NNWESS|)SSSESENESESEENNEESSS(W(WWWWWN(WW(NWNNW|SE)|E)|NN)|EENESEENWNNESENNNWSWNNENWNNEENWWNWWWWWNNWNENEENESSSEENEENESENEESEEESWWWW(SSWNNWSWNWS(SEESESESENENNN(WSSWENNE|)EEESSEESSWNWWNW(NEWS|)SSSEE(NWES|)SWWWSWSWNWSSW(SSWSEENESEEENESEEENNNNESENNENNNEENESEESSSWNWSWW(NNE(S|EE)|SEESEESESWWS(EEEENNW(NENWNENWNENWNW(WWNENWNENNEENE(SSSWNWSSES(W|E(S|N))|NWNWSWNNNNNENEE(SWSWSSENE(N|SS)|NWWWSWNNWNWNEESENENNESSSWS(W|EENNNNNNWNWSWS(EE|SSWWNWSWWWSSENESSSE(ESWSWNWWWSESSESWSEENEENN(WSWNWN|E(NWES|)SSSWWSWWSEEESS(ENN(NWES|)EE|SWSESWWWWW(SE(SSW(S(E|WNWSS(SWSWNW(NEEWWS|)WSES(WSWNW(NEWS|)W|EEE(SWEN|)N)|EE))|N)|EE)|NNESEENNN(ESNW|)WWWS(EESNWW|)WNWS(SSENSWNN|)WNNENNESSEENWNNNNWSSWNWNNNWWSWNNENENNNWWNWNEENNNEEEENENWWSWWNENENEENWNENESSSESW(SSSWSESWSWSE(ENEE(SWEN|)NWNNESEESE(NENWWWNWWNEENNNW(WNEEESSSESS(WNSE|)EEENE(SS(WW|S)|NNNWNWNENWWSW(SSSEN(N|ESS(SWN|EN))|WNWWW(SEEWWN|)WWWSWWSESWWNNNNW(SSW(N|SESWWSWWNWWWNN(NWSSSW(WSSESENN(ESSSENEN(WNEWSE|)EESENESS(WWSESE(SWWNWNN(WSSSESWSESWSESSESSE(SWSEESSSESE(NN(ESSNNW|)NW(NENSWS|)S|SWWNWNNWSSWNWNNWWWNNWNNEEEE(ESSWS(ES(EE|S)|WWNN(W|E(E|S)))|NNWNWWNENWNNWWSESWSWW(SEESE(NN|EES(WWWSSWNNNWSSWSW(SSEEN(N|EESWSESWWS(EEESS(S|ENE(E(E|NWWN(WNNSSE|)EE)|S))|WS(WSWWNN(NNESS(S|ENNE(S|E))|WWSWSSWSS(WNNN(WSS|ENW)|ENEEEE(SWW(SESWSEESWWSSW(SES(WWNSEE|)ENNNEEESWWSEEENEESE(SSSWNW(N(E|N|WWWWS(W|S))|SS)|NNNNWWSS(ENSW|)WNNN(WW(SSEN|WNEN)|EEE))|NNN)|W)|NWWN(WSNE|)N)))|E))|W)|NW(N|W))|E))|NNNNE(NN(E(NWNSES|)ESS(WNSE|)EN(EESSS(WNNSSE|)SS|N)|WSWWWS)|SSS))))|NNENWN(EESNWW|)NW(SS|NN))|N)|N)|ENNN(W|E(S|E)))|W)|NN)|EEEES(ENSW|)(S|WWW)))|NNENWWWNNNNESENESSWWSEEENEESWSSENENENESEENWNENWNENENNWNWSWNNNWWNEEEENESESESESWW(SSENESENE(NNNW(NW(WNNNNNESEE(NNNNWNENWNWSWWWSESENESSS(E(N|S)|WWWWNE(NWWWNNNNEEES(WSSWNN|ENNWNNWSWNWNNNWSWWWNNEE(SWEN|)NEEEESW(SEEEESSW(SSEEN(ENE(NNWW(NENNWSWWW(SEEWWN|)NNWNNWNNNNNENENESSWSSW(N|SSESES(ENENNESE(NNWNWSWSW(SEWN|)(W|NNENEENNE(NWWW(SESWENWN|)NENNESSENNNNWWWWNWNNNNWWN(EEESENESSWSW(SESENESENNW(NNE(NWES|)S|W)|N)|WSWWSSWWSSENESESSWWSEEENNENWNNEN(WWSSNNEE|)ESS(W|SSESEE(SSWNWWSESESWWWN(E|WWWWSWWWNWNENNEE(N(EE|WWWNENE(NNEENWWN(WSSWWWSES(ENEWSW|)WWSWWWNNENNN(WSSWNWWWN(EEE|WSWSEESESSWNWSSSWSESEESENNNWN(WSSEWNNE|)ENNN(NWES|)ESSSESSW(SESSW(SSWSSSESSENNEESSSENESSSWWN(WWN(ENNSSW|)WWSWNWNEN(ESNW|)NNWWWWSSEE(ENWWEESW|)SWSESSE(N|EESWSESEESESWWSWWWNWWSSWNNNWWNEEEES(W|EN(ESE(SWEN|)E|NWN(E|WWWS(WNWWNNNW(SSWWSSSW(NN|SEEENN(ESE(N|SWSEEESSSSESESSENNENWWN(EN(ESESSENNESSESWWSSSWWWSSENESEESENESEENENENWNWSWNWWW(NEENESENNNNESESSS(WNNSSE|)ES(ESEESESWWWW(SSESEEEENEENE(SSWWSEE(ENESE(S|NNNWWSE(WNEESSNNWWSE|))|SWWWWN(E|WSWWSWNWNE(EE|NWWSSSWWSSWWSWWWNWNEENWWNWWWNEEENWWNWSWNWWNNWNWNENNWSWN(NNESEENNW(WN(WSNE|)NEEN(W|ESS(SSESWSSSW(NN|SEEESWS(WNSE|)EE(EES(W|ESEN(NWES|)ESSS(WWNEWSEE|)ESS(W(SWEN|)N|ENNNWNNESEE(SWSEWNEN|)N(W|EEN(W|N))))|NNNN(EEENNWS(NESSWWEENNWS|)|WSWNNEN(SWSSENSWNNEN|))))|WW))|S)|WSSSSWWSEESENN(NN|ESSSE(NN|SSSWNWN(E|WSSESWSWWNENNW(NNE(NWW(W|NNN(WW|EN(ESNW|)W))|S|EE)|SW(SSSES(W|ENEEES(ESSSSENNNNENESSWSEENNNENNE(NWWSSWNWW(NNEN(WNE|ESSW)|WWS(ESENEWSWNW|)W)|SSESESENEES(ENNESSESS(W(SEWN|)N|ENNNWNNEES(W|SESSW(SEENEEEENWWNWSWNNNEEE(S(SEE(NWNEWSES|)SSE(NE(E|S)|SSSWNNWWWSS(ENESS|WNN))|WW)|NNWSW(N|WW(SS|W(WW|N))))|N)))|WSWWWNWNWS(NESESEWNWNWS|)))|WW))|W)))))))))|NNWSWNNNNWWS(WNNNWSS(S|WNWNNE(S|ENWWWNWNEESEEN(ESEEN(ESSS(WSS(ENSW|)WNNWNEE(WWSESSNNWNEE|)|E(EE|N))|W)|NNWWWWS(EEESNWWW|)WSW(NNNNN(WWW(SEESNWWN|)N(EE|N)|EEENNESSSES(WWWN(WSSNNE|)E|ENEENNEES(EE(E|NWN(NNWSSWNNWWNNNNWWSESSSWWNW(WWNNNEESE(NNEN(EEES(SEESSWW(NEWS|)SEEENNNNWNE(NWWSSNNEES|)E(E|S)|WW)|WWWNNWNNNN(ENESSS(ENSW|)W(SESSEWNNWN|)N|WWSESWSSSE(ESWS(EEE|SSWNNW(NE|SWSE))|NN)))|S(ES|WWN))|SSEESESWSEENNENWW(EESWSSNNENWW|))|E))|W)))|S(SWS(ESWENW|)WNN(NESNWS|)WWW|E)))))|SE(SSS(E|WSWWN(E|W))|N)))|N(N|EE))|W)|SES(E(N|E(E|S))|WW))|N)|W))|W(NEWS|)S))|N(NESENN(WW|NNNEES(SW(SESWSEESWSWS(WNNE|EEENW)|N)|EEENWNNWWWWS(EEESNWWW|)WNNENESEEE(EESWSEE(SWSE|NES)|NWNW(NWNENWNWNWW(NNNEESS(WNSE|)ESEE(NNN(WWSESNWNEE|)E|E(SSSW(NNWESS|)S|E))|WSEESESSS(E|WNNWWWWWNW(NEESE(EE|NN)|WWSESE(N|EEEEESWSSWSS(ENE(NNEWSS|)S|WW(S|NW(S|NNEN(WWSSWW(NENWNE|S(EE|SWSSE(N|S(S|WWNNNWWWN(WSWENE|)NESEEENWW(EESWWWEEENWW|)))))|ES(ENSW|)S(S|W)))))))))|S))))|W))|EE)))))|E)|N)|N))|EES(SSW(SWEN|)NN|ENESEN))|EEEE)|S))|SS(SWNNSSEN|)EEEEENNE(WSSWWWEEENNE|)))|EE)))|SSS))|SSS(SSS|WW(WWSE|NEN)))|W))|S(E|S))|SSWSS(E(S|N)|WW(NEWS|)S))|W)|WN(WWSEWNEE|)E)|WW))|EE))|SWSS(WNNSSE|)E(N|S))|S)|SS)|SSWWWSESEE(NWES|)SWWSSWSESWWSWWNN(E(S|ENWNNNNE(SSE(SWEN|)N|N))|WSWSS(WNW(NENEWSWS|)WS(E|WW(SEWN|)N(W|NN|E))|E(N|EEE(S|ENESEE(NWNENNW(NEWS|)S|SSS))))))|NW(S|WN(WSNE|)E)))))|SS)|S(WWNSEE|)S)|SWSSSWS(W(NNENWNENNWNN(EESWENWW|)WSSS(W|E)|W)|SE(SWSNEN|)NEN(EESWENWW|)NN))|WW))))|N)))))|SSSSS(S|WW))|S)|WWNWSWWWNEEN(N(N|ESE(E(E|S)|N))|WW)))|NNNWNN(E(ES(W|EE(EN|SWW))|N)|W))|WWWWNNWSS(NNESSEWNNWSS|))|N))|WNNWNNWSW(SEWN|)NNWNNESENESE(S(WW|SS)|EEENENE(EEESWWWS(E|W)|NWWNWSWWN(E|WSS(W(N|WWW)|ESENE(S|E))))))|N)|N)|NNWSSWS(ESNW|)WW(NENNES|WW)))|E))|ESSENES(EN|SW))|E))|WNWWS(E|WNW(S|NENENN(EESSES(WW(NN|W)|ENNNESEENEEES(WWSWSE(ENESNWSW|)SS|EEENNE(SSEEWWNN|)NWN(WSSSWNWWWWW(WWWSSNNEEE|)(NEN(ESENSWNW|)W|S)|E)))|NW(NEWS|)WSWS(SENENSWSWN|)W)))))|WW)))|WNWNNNENW(W|N))|WWWWNE(NWES|)EE))|NNEENNN(WSSWNN|NNE(E|NWN(WWNENNNENNEE(SWSEE(EE|NN)|NNN(E|WSW(WS(EE|SWS(SSS|WWNENN(ESNW|)NWSW(NN(N(N|W)|E)|S(SW(SEWN|)NN|E))|E))|N)))|E)))))|E))|N)|W)))|W)|N))))))|N)))|WW))|E(EEE(E|SS)|S))|S)))|E))))|S))|W)|SS(E|S)))|W)|N)))|WS(EEEEE(NWES|)S(ENSW|)W|WWN(NWSNES|)E))))|S)|EESS(E(ESESEWNWNW|)N|W(WNEWSE|)S)))|W)))|NN)))))|E(ENSW|)SS)|S)|NNEE(SWEN|)N(EEN(EEEN(ESEEN(ESSSWSES(SWWWS(SWSWNNNNNENEN(WWSWNSENEE|)E(SSWS(WSSNNE|)EE|E)|EEE)|ENENWNNNESSE(S|E|N))|NNW(NN(ESEWNW|)WN(NNNWSNESSS|)E|S(WW|S)))|W)|W)|WW))))))|W)$
