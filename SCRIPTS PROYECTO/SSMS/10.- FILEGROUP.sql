USE master
GO


DROP DATABASE IF EXISTS TRIALBBM_INCLUDENDF_INCLUDENDF
GO



CREATE DATABASE TRIALBBM_INCLUDENDF_INCLUDENDF
    ON
        PRIMARY
            ( NAME = BBM_ASPACE,
            FILENAME = 'C:\BBMTRIGGERS_TRIAL\BBM_ASPACE_MDF.mdf',
            SIZE = 10MB,
            MAXSIZE = 50,
            FILEGROWTH = 5% ),
            ( NAME = BBM_Company_2,
            FILENAME = 'C:\BBMTRIGGERS_TRIAL\BBM_ASPACE_NDF1.ndf',
            SIZE = 10MB,
            MAXSIZE = 50,
            FILEGROWTH = 5% ),

                FILEGROUP BBM_USERS_1
                    ( NAME = BBM_Usuario1,
                    FILENAME = 'C:\BBMTRIGGERS_TRIAL\BBM_ASPACE_NDF2.ndf',
                    SIZE = 10MB,
                    MAXSIZE = 50,
                    FILEGROWTH = 5% ),
                    ( NAME = BBM_USERS_EXTENSION,
                    FILENAME = 'C:\BBMTRIGGERS_TRIAL\BBM_ASPACE_NDF3.ndf',
                    SIZE = 10MB,
                    MAXSIZE = 50,
                    FILEGROWTH = 5% ),

                FILEGROUP BBM_EXPEDIENTS
                    ( NAME = BBM_Usuario2,
                    FILENAME = 'C:\BBMTRIGGERS_TRIAL\BBM_ASPACE_NDF4.ndf',
                    SIZE = 10MB,
                    MAXSIZE = 50,
                    FILEGROWTH = 5% ),
                    ( NAME = BBM_EXPEDIENTS_EXTENSION,
                    FILENAME = 'C:\BBMTRIGGERS_TRIAL\BBM_ASPACE_NDF5.ndf',
                    SIZE = 10MB,
                    MAXSIZE = 50,
                    FILEGROWTH = 5% )
        LOG ON
            ( NAME = BBM_ASPACE_LOG,
            FILENAME = 'C:\BBMTRIGGERS_TRIAL\BBM_ASPACE_LOGS.ldf',
            SIZE = 10MB,
            MAXSIZE = 50,
            FILEGROWTH = 5%) ;
GO