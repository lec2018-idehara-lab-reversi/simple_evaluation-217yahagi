final int KURO = 1;
final int SHIRO = -1;
final int AKI = 0;
final int SOTO = 255;
final int BANSIZE = 640;
final int CELLSIZE = BANSIZE / 8;
final int STONESIZE = round(CELLSIZE * 0.9);

final int HITO = 1;
final int COMP = 2;

final int[][] tensu =
  { {0,0,  0,0,0,0,0,0,0,0},
    {0,30,-12,0,-1,-1,0,-12,30,0},
    {0,-12,-15,-3,-3,-3,-3,-15,-12,0},
    {0,0,-3,0,-1,-1,0,-3,0,0},
    {0,-1,-3,-1,-1,-1,-1,-3,-1,0},
    {0,-1,-3,-1,-1,-1,-1,-3,-1,0},
    {0,0,-3,0,-1,-1,0,-3,0,0},
    {0,-12,-15,-3,-3,-3,-3,-15,-12,0},
    {0,30,-12,0,-1,-1,0,-12,30,0},
    {0,0,  0,0,0,0,0,0,0,0} };

int KUROBAN = HITO;
int SHIROBAN = COMP;

int[][] ban;
int teban;
// 連続パス回数
int passcount;

void setup()
{
  teban = KURO;
  passcount = 0;

  size(640, 640);
  ban = new int[10][10];
  for(int y=0; y<10; y++)
  {
    for(int x=0; x<10; x++)
    {
      ban[x][y] = AKI;
      if( x==0 || x==9 || y==0 || y==9 )
      {
        ban[x][y] = SOTO;
      }
      else
      {
        ban[x][y] = AKI;
      }
    }
  }
  ban[4][4] = SHIRO;
  ban[5][5] = SHIRO;
  ban[4][5] = KURO;
  ban[5][4] = KURO;
}

void showBan(int[][] b)
{
  // もし、現在の手番の人が石を置けないならば
  // 連続パス回数を１回増やして、手番をさらに先に送る
  if( countPlaceable(b, teban) == 0 )
  {
    teban = -teban;
    passcount++;
  }

  // 連続パス回数が２回になったら（＝白黒どちらもパスしなければいけなかったら）
  // ゲーム終了
  if( passcount >= 2 )
  {
    showResult(ban);
  }

  // コンピュータの番ならば、石を置く
  if( (KUROBAN == COMP && teban == KURO) || (SHIROBAN == COMP && teban == SHIRO) )
    autoPutStone();

  background(0,96,0);
  for(int i=0; i<9; i++)
  {
    line(0,i*CELLSIZE,BANSIZE,i*CELLSIZE);
    line(i*CELLSIZE,0,i*CELLSIZE,BANSIZE);
  }

  for(int y=1; y<=8; y++)
  {
    for(int x=1; x<=8; x++)
    {
      switch(b[x][y])
      {
        case SOTO:
          break;
        case AKI:
          break;
        case KURO:
          fill(0);
          ellipse( round((x-0.5)*CELLSIZE), round((y-0.5)*CELLSIZE), STONESIZE, STONESIZE );
          break;
        case SHIRO:
          fill(255);
          ellipse( round((x-0.5)*CELLSIZE), round((y-0.5)*CELLSIZE), STONESIZE, STONESIZE );
          break;
      }

      // おける場所には赤丸
      if( turn(ban, teban, x, y) != 0 )
      {
        fill(255,0,0);
        ellipse( round((x-0.5)*CELLSIZE), round((y-0.5)*CELLSIZE), 10,10);
      }
    }
  }
}

void draw()
{
  showBan(ban);
}

void mouseClicked()
{
  // 人間の手番でなければ、何もせず終了
  if( ! ((KUROBAN == HITO && teban == KURO) || (SHIROBAN == HITO && teban == SHIRO)) )
    return;

  int gx = mouseX / CELLSIZE + 1;
  int gy = mouseY / CELLSIZE + 1;

  // もしその場所に石をおいて良いならば
  if( turn(ban, teban, gx, gy) != 0 )
  {
    put(ban, teban, gx, gy);
    teban = -teban;
    // 石をおいたので、連続パス回数は０回に戻る
    passcount = 0;
  }

}

// 盤面 b に、色 te の石を (x,y) に置こうとしたとき、(dx,dy) 方向に相手の石が何個ひっくり返せるか数えて答える関数
// (dx,dy) は、(-1,-1),(-1,0),(-1,1),(0,-1),(0,1),(1,-1),(1,0),(1,1) で８方向
int turnSub(int[][] b, int te, int x, int y, int dx, int dy)
{
  // 相手の石を数える変数
  int result = 0;

  // まず、置こうとしている場所の隣に移動する
  x += dx;
  y += dy;

  // そこが「相手の石の色である」あいだ、その数を数えながらその先に移動していく。
  while( b[x][y] == -te )
  {
    result++;
    x += dx;
    y += dy;
  }

  // 繰り返しを抜けるのは「相手の石でない」ものを発見したとき。このとき自分の石を見ていれば、ひっくり返せる。それまで
  // 自分の石でなければ、それまで何個数えていても、ひっくり返せるのは０個。
  if( b[x][y] == te )
  {
    return result;
  }
  else
  {
    return 0;
  }
}

// 盤面 b に、色 te の石を (x,y) に置こうとしたとき、全部で相手の石が何個ひっくり返せるか数えて答える関数
int turn(int[][] b, int te, int x, int y)
{
  // 空いているかどうか、ここでチェックすることにする。
  // 置こうとしてる場所が AKI でないなら、一個もひっくり返せない。
  if( b[x][y] != AKI )
  {
    return 0;
  }

  // 総数を数える準備。
  int result = 0;

  // (-1,-1) 方向の数を数える。
  result += turnSub(b, te, x, y, -1, -1);
  // あと７方向全部数えて足し合わせる。
  result += turnSub(b, te, x, y, -1,  0);
  result += turnSub(b, te, x, y, -1,  1);
  result += turnSub(b, te, x, y,  0, -1);
  result += turnSub(b, te, x, y,  0,  1);
  result += turnSub(b, te, x, y,  1, -1);
  result += turnSub(b, te, x, y,  1,  0);
  result += turnSub(b, te, x, y,  1,  1);

  return result;
}


int putSub(int[][] b, int te, int x, int y, int dx, int dy)
{
  int result = turnSub(b, te, x, y, dx, dy);
  // もしもその方向に石をひっくり返せないなら、何もせず０を返す。
  if( result == 0 )
    return 0;

  // そうでなければ、一歩動いてから
  x += dx;
  y += dy;

  // 相手の石が見える間、石をひっくり返していく
  while( b[x][y] == -te )
  {
    b[x][y] = te;
    x += dx;
    y += dy;
  }

  return result;
}


int put(int[][] b, int te, int x, int y)
{
// ８方向に putsub を呼び出す。
  int result = 0;

  result += putSub(b, te, x, y, -1, -1);
  result += putSub(b, te, x, y, -1,  0);
  result += putSub(b, te, x, y, -1,  1);
  result += putSub(b, te, x, y,  0, -1);
  result += putSub(b, te, x, y,  0,  1);
  result += putSub(b, te, x, y,  1, -1);
  result += putSub(b, te, x, y,  1,  0);
  result += putSub(b, te, x, y,  1,  1);

  b[x][y] = te;
  return 0;
}

// 置ける場所を数える関数（盤面 b、手番 te）　→　答：置ける場所の数
int countPlaceable(int[][] b, int te)
{
  int result = 0;
  for(int y=1; y<=8; y++)
  {
    for(int x=1; x<=8; x++)
    {
      if( turn(b, te, x, y) != 0 )
        result++;
    }
  }
  return result;
}

void showResult(int[][] b)
{
  int countb, countw;
  countb = countw = 0;
  for(int y=1; y<=8; y++)
  {
    for(int x=1; x<=8; x++)
    {
      // もし b[x][y] が黒なら countb を１増やす。
      // もし b[x][y] が白なら countw を１増やす。
      if( b[x][y] == KURO ) countb++;
      if( b[x][y] == SHIRO ) countw++;
    }
  }

  println( "Black: " + countb + " / White:" + countw );
  // どっちが勝ちか（あるいは引き分けか）判定して表示する
  noLoop();
}

void autoPutStone()
{
  // どこに置きたいか問い合わせて
  Move m = getMove(ban, teban);

  // パスでなければ置く。手番を変える。連続パス回数を０にする
  if( m.x != 0 )
  {
    put(ban, teban, m.x, m.y);
    teban = -teban;
    passcount = 0;
  }
  // パスなら、手番を変える。連続パス回数を１増やす。
  else
  {
    teban = -teban;
    passcount ++;
  }
}

Move getMove(int[][] b, int te)
{
  Move result = new Move();
  int currentScore = -999999;
  for(int y=1; y<=8; y++)
  {
    for(int x=1; x<=8; x++)
    {
      if( turn(b, te, x, y) != 0 )
      {
        int newScore = evaluateMove(b, te, x, y);
        // もしも新しい手の価値のほうが、今覚えている手の価値より高いならば
        if( currentScore<newScore )
        {
          // その手を覚え
          result.x = x;
          result.y = y;
          // 新しい手の価値を覚える
          currentScore = newScore;
        }
      }
    }
  }
  result.value = currentScore;
  return result;
}


int evaluateMove(int[][] b, int te, int x, int y)
{
  int result;
  
  // 現在の手の評価は「盤面の点数」
  result = tensu[x][y];

  return result;
}
