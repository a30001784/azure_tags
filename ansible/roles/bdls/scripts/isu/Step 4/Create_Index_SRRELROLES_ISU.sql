USE $(database)
GO

/****** Create index for SRRELROLES TAKES 40 mins ****/
CREATE NONCLUSTERED INDEX [SRRELROLES~003] ON $(schema).[SRRELROLES]
(
	[CLIENT] ASC,
	[UTCTIME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
GO

/****** Object:  Index [SRRELROLES~001]    TAKES 15 mins ****/
CREATE NONCLUSTERED INDEX [SRRELROLES~001] ON $(schema).[SRRELROLES]
(
	[ROLEID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
GO

/****** Object:  Index [SRRELROLES~002]    TAKES 55 mins ****/
CREATE NONCLUSTERED INDEX [SRRELROLES~002] ON $(schema).[SRRELROLES]
(
	[CLIENT] ASC,
	[ROLETYPE] ASC,
	[OBJTYPE] ASC,
	[OBJKEY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
GO
