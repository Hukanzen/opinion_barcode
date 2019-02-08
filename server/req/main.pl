#!/usr/bin/perl
{
	package MyWebServer;
	
	use HTTP::Server::Simple::CGI;
	use base qw(HTTP::Server::Simple::CGI);
	use DBI;
	use Data::Dumper;
	use strict;
	use warnings;
	
	my %dispatch = (
		'/index'   => \&resp_index, # index
		'/insert'  => \&resp_insert, # データの挿入
		'/operate' => \&resp_operate, # 質問番号の調整
		'/analy'   => \&resp_analy, # 解析
	);
	
	my $ques_num=-1; # 質問番号
	
	sub handle_request {
		my $self = shift;
		my $cgi  = shift;
	
		my $path = $cgi->path_info();
		my $handler = $dispatch{$path};
	
		if (ref($handler) eq "CODE") {
			print "HTTP/1.0 200 OK\r\n";
			$handler->($cgi);
			
		} else {
			print "HTTP/1.0 404 Not found\r\n";
			print $cgi->header(-charset=>"utf-8"),
				$cgi->start_html(-lang => 'ja','Not found'),
				$cgi->h1('Not found'),
				$cgi->end_html;
		}
	}
			# print $cgi->header(),
			# 	$cgi->start_html('Not found'),
			# 	$cgi->h1('Not found'),
			# 	$cgi->end_html;
	
	sub resp_index {
		my $cgi  = shift; 
		return if !ref $cgi;
		
		my @urls = (
			$cgi->a({href=>"/index"},"index"),
			$cgi->a({href=>"/hello"},"hello"),
			$cgi->a({href=>"/operate"},"operate"), 
			$cgi->a({href=>"/analy"},"analy"));
		
		print $cgi->header(-charset=>"utf-8"),
			$cgi->start_html(-lang => 'ja',"Index Page");
		print '<ul>';
		foreach(@urls){
			print '<li>';
			print $_;
			print '</li>';
		}
		print '</ul>';
		print $cgi->end_html;
	}
	
	sub resp_insert {
		my $cgi = shift;
		return if !ref $cgi;
		
		my $user = $cgi->param('user'); # ユーザID
		my $opi  = $cgi->param('opi'); # 意見
		
		my $dbh = DBI->connect("dbi:mysql:database=opinidb;host=mysql;port=3306",'user',
		'password'); #データベースの接続
				
		my $sth = $dbh->prepare("INSERT INTO opinidb.opinion(USER,NUM,OPI) VALUES (?,?,?);");
		$sth->execute($user,$ques_num,$opi); # SQL生成，実行

		$sth->finish;
		$dbh->disconnect; #接続終了
		
		
		print $cgi->header(-charset=>"utf-8");
		print $cgi->start_html("insert");
		print $cgi->h1("Question number is $ques_num");
		print "<p>ユーザ:$user, 意見$opi</p>";
		print $cgi->end_html;
	}
	
	sub resp_operate {
		my $cgi = shift;
		return if !ref $cgi;
		
		print $cgi->header(-charset=>"utf-8");
		print $cgi->start_html(-lang => 'ja',"operate");
		
		my $ch = $cgi->param('ch_ques_num');
		
		if((defined($ch)) && ($ch=~m/\d/)){
			$ques_num = $cgi->param('ch_ques_num') ; # 質問番号を受け取る
		}
		
		print "現在の質問番号: " .$ques_num."<br>";
		print '質問番号の変更',
			'<form action=# method=POST>',
			'<input type="number" name="ch_ques_num"/>',
			'<input type="submit" value="send">',
			'</form>'; # 質問番号を入力
		print $cgi->end_html;
	}
	
	sub resp_analy {
		my $cgi=shift;
		return if !ref $cgi;
		
		# 質問番号ごとにパターン数の数をcount
		my $dbh = DBI->connect("dbi:mysql:database=$ENV{MYSQLDB};host=mysql;port=3306",$ENV{MYSQLUSER},$ENV{MYSQLPASSWORD}); #データベースの接続				
		
		print $cgi->header(-charset=>"utf-8");
		print $cgi->start_html(-lang => 'ja',"analy");
		
		my @opilist = ('agree','opposite','neutral');

		foreach(@opilist){
			print $cgi->h2("count : ".$_);

			my $sth = $dbh->prepare("SELECT NUM AS ques_num , COUNT(*) AS countopi FROM $ENV{MYSQLDB}.$ENV{MYSQLTABLE} WHERE OPI LIKE '\%".$_."\%'  GROUP BY ques_num");
			$sth->execute(); # SQL生成，実行
		
			print '<table border=1>';
			print '<tr><th>質問番号</th><th>選んだ人数</th></tr>';
			while(my $datahash = $sth->fetchrow_hashref){
				print '<tr><td>'.$datahash->{'ques_num'}.'</td><td>'.$datahash->{'countopi'}.'</td></tr>';
			}
			print '</table>';
			$sth->finish;
		}
		
		print $cgi->end_html;
		
	
		$dbh->disconnect; #接続終了
	}
	
} 

# start the server on port 80
my $pid = MyWebServer->new(80)->run();#->background();
#print "Use 'kill $pid' to stop server.\n";
