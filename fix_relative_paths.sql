/* Create in-memory temp table for variables */
    --BEGIN;

    PRAGMA temp_store = 2; /* 2 means use in-memory */
    CREATE TEMP TABLE _Variables(Name TEXT, RealValue REAL, IntegerValue INTEGER, BlobValue BLOB, TextValue TEXT);

    /* Declaring a variable */
    INSERT INTO _Variables (Name) VALUES ('VariableName');

    /* Assigning a variable (pick the right storage class) */
    --UPDATE _Variables SET IntegerValue = 123 WHERE Name = 'VariableName';

    /* Getting variable value (use within expression) */
    --SELECT (SELECT coalesce(RealValue, IntegerValue, BlobValue, TextValue) FROM _Variables WHERE Name = 'VariableName' LIMIT 1);


	/* Get current Directory and Catalog File */
    INSERT INTO _Variables (Name,TextValue) VALUES ('CatalogDBLocation', 
	substr((SELECT name FROM fsdir('.','..') WHERE name LIKE '%catalogdb%' LIMIT 1),3)
	);
    INSERT INTO _Variables (Name,TextValue) VALUES ('CatalogDBFile', 
	substr((SELECT name FROM fsdir('.') WHERE name LIKE '%catalogdb%' LIMIT 1),3)
	);
    INSERT INTO _Variables (Name,TextValue) VALUES ('CatalogFolder', 
	rtrim((SELECT TextValue FROM _Variables WHERE Name = 'CatalogDBLocation' LIMIT 1),(SELECT TextValue FROM _Variables WHERE Name = 'CatalogDBFile' LIMIT 1))
	);


	--INSERT INTO _Variables (Name,TextValue) VALUES ('CurrentDir', readfile('CurrentDir.txt'));


    --SELECT (SELECT coalesce(RealValue, IntegerValue, BlobValue, TextValue) FROM _Variables WHERE Name = 'CurrentDir' LIMIT 1);

    --SELECT name,(mode & 0170000)&0040000==0,mtime FROM fsdir('.','..');	
	
	--Folders to Fix (if found)
	INSERT INTO _Variables (Name,TextValue)
	SELECT 'FixFolders',substr(name,3) FROM fsdir('.','..') WHERE ((mode & 0170000)&0040000)=0 AND length(name)>2;
	--SELECT 'found catalogdb';
	--SELECT substr((SELECT name,(mode & 0170000)&0040000==0 as adir,mtime FROM fsdir('.','..') WHERE name LIKE '%catalogdb%'),3);


	

	
	SELECT * FROM _Variables;
	
	SELECT instr(ZPATHLOCATION.ZRELATIVEPATH,(SELECT TextValue FROM _Variables WHERE Name = 'CatalogFolder' LIMIT 1))
	,substr(ZPATHLOCATION.ZRELATIVEPATH,
	instr(ZPATHLOCATION.ZRELATIVEPATH,(SELECT TextValue FROM _Variables WHERE Name = 'CatalogFolder' LIMIT 1))+length((SELECT TextValue FROM _Variables WHERE Name = 'CatalogFolder' LIMIT 1))), 
	ZPATHLOCATION.ZRELATIVEPATH 
	FROM ZPATHLOCATION
	WHERE ZPATHLOCATION.ZRELATIVEPATH LIKE '%'+(SELECT TextValue FROM _Variables WHERE Name = 'CatalogFolder' LIMIT 1)+'%';

	
	UPDATE ZPATHLOCATION 
	SET ZPATHLOCATION.ZWINROOT= ''
	SET ZPATHLOCATION.ZMACROOT = ''
	SET ZPATHLOCATION.ZISRELATIVE ='1'
	SET ZPATHLOCATION.ZRELATIVEPATH = 'TODO....'
	WHERE ZPATHLOCATION.ZRELATIVEPATH LIKE '%'+(SELECT TextValue FROM _Variables WHERE Name = 'CatalogFolder' LIMIT 1)+'%'

    --DROP TABLE _Variables;
    --END;
	
