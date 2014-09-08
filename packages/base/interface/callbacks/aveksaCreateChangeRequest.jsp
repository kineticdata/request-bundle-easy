<%@page import="java.net.*"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.io.*"%>
<%@page import="javax.net.ssl.*"%>

<%
	String token = null;
	try
	{
		// Create a trust manager that does not validate certificate chains
		TrustManager[] trustAllCerts = new TrustManager[] {new X509TrustManager() {
			public java.security.cert.X509Certificate[] getAcceptedIssuers() {
				return null;
			}
			public void checkClientTrusted(java.security.cert.X509Certificate[] certs, String authType) {
			}
			public void checkServerTrusted(java.security.cert.X509Certificate[] certs, String authType) {
			}
		}
		};
		
		// Install the all-trusting trust manager
		SSLContext sc = SSLContext.getInstance("SSL");
		sc.init(null, trustAllCerts, new java.security.SecureRandom());
		HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());

		// Create all-trusting host name verifier
		HostnameVerifier allHostsValid = new HostnameVerifier() {
			public boolean verify(String hostname, SSLSession session) {
				return true;
			}
		};

		// Install the all-trusting host verifier
		HttpsURLConnection.setDefaultHostnameVerifier(allHostsValid);
	} catch (java.security.NoSuchAlgorithmException e) {
		e.printStackTrace();
	} catch (java.security.KeyManagementException e) {
		e.printStackTrace();
	}
		

	try
	{
		URL urlLoginUser = new URL( "https://74.58.234.142/aveksa/command.submit?cmd=loginUser" );
		URLConnection con = (HttpsURLConnection)urlLoginUser.openConnection();

		// specify that we will send output and accept input
		con.setDoInput(true);
		con.setDoOutput(true);

		con.setConnectTimeout( 20000 );  // long timeout, but not infinite
		con.setReadTimeout( 20000 );
		con.setUseCaches (false);
		con.setDefaultUseCaches (false);

		// tell the web server what we are sending
		con.setRequestProperty ( "Content-Type", "text/xml" );

		OutputStreamWriter writer = new OutputStreamWriter( con.getOutputStream() );
		writer.write( "<username>Kinetic</username><password>K1n3tic</password>" );
		writer.flush();
		writer.close();

		// reading the response
		InputStreamReader reader = new InputStreamReader( con.getInputStream() );

		StringBuilder buf = new StringBuilder();
		char[] cbuf = new char[ 2048 ];
		int num;

		while ( -1 != (num=reader.read( cbuf )))
		{
			buf.append( cbuf, 0, num );
		}

		String result = buf.toString();
		token = result.substring(6);
	}
	catch( Throwable t )
	{
		%>
		FAILED here (Cause: <%t.getCause();%>)
		<%
		//t.printStackTrace( System.out );
	}
	
	if (token != null && token.length() > 0) {
		try {
		String url = "https://74.58.234.142/aveksa/command.submit?cmd=createChangeRequest&token=" + token;
		URL urlCreateChangeReq = new URL( url );
		URLConnection con2 = (HttpsURLConnection)urlCreateChangeReq.openConnection();

		// specify that we will send output and accept input
		con2.setDoInput(true);
		con2.setDoOutput(true);

		con2.setConnectTimeout( 20000 );  // long timeout, but not infinite
		con2.setReadTimeout( 20000 );
		con2.setUseCaches (false);
		con2.setDefaultUseCaches (false);

		// tell the web server what we are sending
		con2.setRequestProperty ( "Content-Type", "text/xml" );

		OutputStreamWriter writer = new OutputStreamWriter( con2.getOutputStream() );
		writer.write( "<Changes><Description>Testing</Description><UserChange><Operation>Add</Operation><User>13</User><BusinessSource>Finance</BusinessSource><Resource>Approve All Expense Reports</Resource><Action></Action></UserChange></Changes>" );
		writer.flush();
		writer.close();

		// reading the response
		InputStreamReader reader = new InputStreamReader( con2.getInputStream() );

		StringBuilder buf = new StringBuilder();
		char[] cbuf = new char[ 2048 ];
		int num;

		while ( -1 != (num=reader.read( cbuf )))
		{
			buf.append( cbuf, 0, num );
		}

		String result = buf.toString();
		
		%>SUCCESSFUL<%
		%><%=result%><%
		} catch (Throwable e) {
			%>
			FAILED submitting request (Cause: <%e.getCause();%>)
			<%
			e.printStackTrace( System.out );
		}
	} else {
	}

%>